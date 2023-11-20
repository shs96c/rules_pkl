load(":providers.bzl", "PklFileInfo")

def _write_pkl_script(ctx, in_runfiles, command):
    # build executable command
    jvm_flags = ""

    pkl_toolchain = ctx.toolchains["//pkl:toolchain_type"]

    executable = pkl_toolchain.cli

    # Build a forest of symlinks. Why do we need to this? It's because
    # when we execute the Pkl, the cache directory cannot be below the
    # working directory of the script because when Pkl searches for
    # dependencies, it effectively does a glob of the current working
    # directory, and if the cache is there then denormalised dependency
    # URIs won't resolve properly.
    working_dir = "%s/work" % ctx.label.name
    cache_dir = "%s/cache" % ctx.label.name

    # A map of {file: path_to_pkl_in_symlinks}
    symlinks = {}
    all_files = depset(transitive = [f[DefaultInfo].files for f in ctx.attr.srcs + ctx.attr.deps + ctx.attr.data]).to_list()
    for file in all_files:
        symlinks[file] = "%s/%s" % (working_dir, file.short_path)

    file_infos = [dep[PklFileInfo] for dep in ctx.attr.srcs + ctx.attr.deps if PklFileInfo in dep]

    for info in file_infos:
        for file in info.dep_files.to_list():
            symlinks[file] = "%s/%s" % (working_dir, file.short_path)
        for cache_entry in info.cache_entries.to_list():
            symlinks[cache_entry.file] = "%s/%s" % (cache_dir, cache_entry.path)

    # Mangle symlinks
    path_to_symlink_target = {}
    for file, path in symlinks.items():
        if file.is_source:
            # Files from the cache hit this code path. For them, the `path`
            # points to the path from the root of the repo (valid from where
            # we run the scripts), but `short_path` starts with `../` and so
            # points to nowhere when we finally merge things
            path_to_symlink_target[file.path] = path
        else:
            # But files that aren't sources will have the correct short_path
            # already, so we can use that.
            path_to_symlink_target[file.short_path] = path

    symlinks_json_file = ctx.actions.declare_file(ctx.label.name + "_symlinks.json")
    ctx.actions.write(output = symlinks_json_file, content = json.encode(path_to_symlink_target))
    pkl_symlink_tool = pkl_toolchain.symlink_tool

    cmd = """#!/usr/bin/env bash

# Create symlinks from the output root to the current folder.
# This allows Pkl to consume generated files.

{symlinks_executable} {symlinks_json_file_path}
ret=$?
if [[ $ret != 0 ]]; then
    echo "Failed creating dependency symlinks in Pkl rule setup." >&2
    exit 1
fi

if [[ $# -gt 0 ]]; then
    output_args=({output_path_flag_name} "$(pwd)/$1")
else
    output_args=()
fi

output=$({executable} {jvm_flags} {command} {format_args} {properties} {expression_args} --working-dir {working_dir} --cache-dir "../cache" "${{output_args[@]}}" {entrypoints})
ret=$?
if [[ $ret != 0 ]]; then
    echo "Failed processing PKL configuration with entrypoint(s) '{entrypoints}' (PWD: $(pwd)):" >&2
    echo "${{output}}"
    exit 1
fi

echo "$output" | grep ❌
ret=$?
if [[ $ret != 0 ]]; then
    exit 0
fi
exit 1
""".format(
        bin_dir = ctx.bin_dir.path,
        executable = executable.short_path if in_runfiles else executable.path,
        expression_args = "-x '{}'".format(ctx.attr.expression) if getattr(ctx.attr, "expression") else "",
        format_args = "--format {}".format(ctx.attr.format) if ctx.attr.format else "",
        jvm_flags = jvm_flags,
        properties = " ".join(["--property '{}'='{}'".format(k, ctx.expand_location(v, ctx.attr.data)) for k, v in ctx.attr.properties.items()]),
        entrypoints = " ".join([f.path for f in (ctx.files.entrypoints or ctx.files.srcs)]),
        output_path_flag_name = "--multiple-file-output-path" if getattr(ctx.attr, "multiple_outputs", False) else "--output-path",
        symlinks_json_file_path = symlinks_json_file.short_path if in_runfiles else symlinks_json_file.path,
        symlinks_executable = pkl_symlink_tool.short_path if in_runfiles else pkl_symlink_tool.path,
        working_dir = working_dir,
        command = command,
    )

    # write shell script
    script = ctx.actions.declare_file(ctx.label.name + "_run.sh")
    ctx.actions.write(
        output = script,
        content = cmd,
        is_executable = True,
    )

    dep_files = []
    for dep in ctx.attr.deps:
        dep_files += [dep.files, dep[PklFileInfo].dep_files]

    if len(ctx.files.srcs) + len(dep_files) == 0:
        fail("{}: Cannot run pkl with no srcs or deps".format(ctx.label))

    for dep in ctx.attr.data:
        dep_files.append(dep[DefaultInfo].files)

    runfiles = ctx.runfiles(
        files = [script, symlinks_json_file] + symlinks.keys() + [pkl_toolchain.cli],
        transitive_files = depset(transitive = dep_files + [pkl_toolchain.symlink_default_runfiles.files, pkl_toolchain.cli_default_runfiles.files]),
    )

    return script, runfiles

_PKL_RUN_ATTRS = {
    "srcs": attr.label_list(
        allow_files = [".pkl"],
    ),
    "data": attr.label_list(
        allow_files = True,
        doc = "Files to make available in the filesystem when building this configuration. These can be accessed by relative path.",
    ),
    "deps": attr.label_list(
        doc = "Other targets to include in the pkl module path when building this configuration. Must be `pkl_*` targets.",
        providers = [
            [PklFileInfo],
        ],
    ),
    "entrypoints": attr.label_list(
        allow_files = [".pkl"],
        doc = "The pkl file to use as an entry point (needs to be part of the srcs). Typically a single file.",
    ),
    "expression": attr.string(
        doc = "A pkl expression to evaluate within the module. Note that the `format` attribute does not affect how this renders.",
    ),
    "format": attr.string(
        doc = "The format of the generated file to pass when calling `pkl`. See https://pages.github.pie.apple.com/pkl/main/current/pkl-cli/index.html#options.",
    ),
    "multiple_outputs": attr.bool(
        doc = "Whether to expect to render multiple file outputs to a single directory with the name of the target (see https://pkl.apple.com/main/current/language-reference/index.html#multiple-file-output). This flag is mutually exclusive with the `out` attribute.",
    ),
    "out": attr.output(
        doc = "Name of the output file to generate. Defaults to `<rule name>.<format>`. If the format attribute is unset, use `<rule name>.pcf`. This flag is mutually exclusive with the `multiple_outputs` attribute.",
    ),
    "properties": attr.string_dict(
        doc = """Dictionary of name value pairs used to pass in PKL external properties
            See the Pkl docs: https://pages.github.pie.apple.com/pkl/main/current/language-reference/index.html#resources""",
    ),
}

def _pkl_run_impl(ctx):
    script, runfiles = _write_pkl_script(ctx, in_runfiles = False, command = "eval")

    if ctx.attr.out and ctx.attr.multiple_outputs:
        fail("pkl_run: Can't specify both `multiple_outputs` and `out` for target {}".format(ctx.label))

    output_format = ctx.attr.format or "pcf"
    if ctx.attr.out == None:
        if ctx.attr.multiple_outputs:
            script_output = ctx.actions.declare_directory(ctx.attr.name)
        else:
            script_output_name = ctx.attr.name + "." + output_format
            script_output = ctx.actions.declare_file(script_output_name)
    else:
        script_output = ctx.outputs.out

    outputs = [script_output]

    pkl_toolchain = ctx.toolchains["//pkl:toolchain_type"]

    result = ctx.actions.run(
        inputs = runfiles.files,
        outputs = outputs,
        executable = script,
        tools = [
            pkl_toolchain.cli_files_to_run,
            pkl_toolchain.symlink_files_to_run,
        ],
        arguments = [script_output.path],
        mnemonic = "PklRun",
    )
    return [DefaultInfo(files = depset(outputs), runfiles = ctx.runfiles(outputs))]

pkl_run = rule(
    _pkl_run_impl,
    attrs = _PKL_RUN_ATTRS,
    toolchains = [
        "//pkl:toolchain_type",
    ],
)

def _pkl_test_impl(ctx):
    script, runfiles = _write_pkl_script(ctx, in_runfiles = True, command = "test")
    return [DefaultInfo(executable = script, runfiles = runfiles)]

pkl_test = rule(
    implementation = _pkl_test_impl,
    attrs = _PKL_RUN_ATTRS,
    test = True,
    toolchains = [
        "//pkl:toolchain_type",
    ],
)
