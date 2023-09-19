load("//pcl/private:providers.bzl", "PclFileInfo")

# A set of JVM flags to use when running Pcl rules on the RBE and with the federation.
PCL_JVM_FLAGS = [
    # By default, the JVM sets this to 25% but our RBE nodes have 4GiB memory.
    "-XX:MaxRAMPercentage=80.0",
    # Pcl configurations that creates large data structures that are operated on and amended repeatedly,
    # can use a lot of available memory.
    #
    # Reclaim these large structures eagerly rather than waiting for a GC ratio/threshold to be hit.
    "-XX:+UseG1GC",  # Has been the default since JDK9. Set it explicitly.
    "-XX:+UnlockExperimentalVMOptions",
    # Increase heap free ratios to force reduction of the heap earlier.
    "-XX:MaxHeapFreeRatio=30",
    "-XX:MinHeapFreeRatio=10",
]

def _write_pcl_script(ctx, in_runfiles):
    is_java_executor = ctx.attr.executor == "java"

    # build executable command

    # Add extra jvm_flags if necessary
    if is_java_executor:
        jvm_flags = " ".join(["--jvm_flag=%s" % flag for flag in ctx.attr.jvm_flags])
        executable = ctx.executable._pcl_java_cli
    else:
        jvm_flags = ""
        executable = ctx.executable._pcl_cli

    # Build a forest of symlinks. Why do we need to this? It's because
    # rdar://107049641 means that when we execute the Pcl, the cache
    # directory cannot be below the working directory of the script
    # because when Pcl searches for dependencies, it effectively does
    # a glob of the current working directory, and if the cache is
    # there then denormalised applehub URIs won't resolve properly.
    working_dir = "%s/work" % ctx.label.name
    cache_dir = "%s/cache" % ctx.label.name

    # A map of {file: path_to_pcl_in_symlinks}
    symlinks = {}

    all_files = depset(transitive = [f[DefaultInfo].files for f in ctx.attr.srcs + ctx.attr.deps + ctx.attr.data]).to_list()
    for file in all_files:
        symlinks[file] = "%s/%s" % (working_dir, file.short_path)

    file_infos = [dep[PclFileInfo] for dep in ctx.attr.srcs + ctx.attr.deps if PclFileInfo in dep]
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
    pcl_symlink_tool = ctx.executable._pcl_symlink_tool

    cmd = """#!/usr/bin/env bash

# Create symlinks from the output root to the current folder.
# This allows Pcl to consume generated files.
{symlinks_executable} {symlinks_json_file_path}
ret=$?
if [[ $ret != 0 ]]; then
    echo "Failed creating dependency symlinks in Pcl rule setup." >&2
    exit 1
fi

if [[ $# -gt 0 ]]; then
    output_args=({output_path_flag_name} "$(pwd)/$1")
else
    output_args=()
fi

output=$({executable} {jvm_flags} {format_args} {properties} {expression_args} --working-dir {working_dir} --cache-dir "../cache" "${{output_args[@]}}" {entrypoints})
ret=$?
if [[ $ret != 0 ]]; then
    echo "Failed processing PCL configuration with entrypoint(s) '{entrypoints}' (PWD: $(pwd)):" >&2
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
        symlinks_executable = pcl_symlink_tool.short_path if in_runfiles else pcl_symlink_tool.path,
        working_dir = working_dir,
    )

    # write shell script
    script = ctx.actions.declare_file(ctx.label.name + "_run.sh")
    ctx.actions.write(
        output = script,
        content = cmd,
        is_executable = True,
    )

    dep_files = [ctx.attr._pcl_symlink_tool[DefaultInfo].files]
    for dep in ctx.attr.deps:
        dep_files += [dep.files, dep[PclFileInfo].dep_files]

    if len(ctx.files.srcs) + len(dep_files) == 0:
        fail("{}: Cannot run pcl with no srcs or deps".format(ctx.label))

    if is_java_executor:
        dep_files.append(ctx.attr._pcl_java_cli[DefaultInfo].files)
    else:
        dep_files.append(ctx.attr._pcl_cli[DefaultInfo].files)

    for dep in ctx.attr.data:
        dep_files.append(dep[DefaultInfo].files)

    runfiles = ctx.runfiles(
        files = [script, symlinks_json_file] + symlinks.keys(),
        transitive_files = depset(transitive = dep_files),
    ).merge(
        ctx.attr._pcl_symlink_tool[DefaultInfo].default_runfiles,
    )

    if is_java_executor:
        runfiles = runfiles.merge(ctx.attr._pcl_java_cli[DefaultInfo].default_runfiles)

    return script, runfiles

_PCL_RUN_ATTRS = {
    "srcs": attr.label_list(
        allow_files = [".pcl"],
    ),
    "data": attr.label_list(
        allow_files = True,
        doc = "Files to make available in the filesystem when building this configuration. These can be accessed by relative path.",
    ),
    "deps": attr.label_list(
        doc = "Other targets to include in the pcl module path when building this configuration. Must be `pcl_*` targets.",
        providers = [
            [PclFileInfo],
        ],
    ),
    "entrypoints": attr.label_list(
        allow_files = [".pcl"],
        doc = "The pcl file to use as an entry point (needs to be part of the srcs). Typically a single file.",
    ),
    "expression": attr.string(
        doc = "A pcl expression to evaluate within the module. Note that the `format` attribute does not affect how this renders.",
    ),
    "format": attr.string(
        doc = "The format of the generated file to pass when calling `pcl`. See https://pages.github.pie.apple.com/pcl/main/current/pcl-cli/index.html#options.",
    ),
    "multiple_outputs": attr.bool(
        doc = "Whether to expect to render multiple file outputs to a single directory with the name of the target (see https://pcl.apple.com/main/current/language-reference/index.html#multiple-file-output). This flag is mutually exclusive with the `out` attribute.",
    ),
    "out": attr.output(
        doc = "Name of the output file to generate. Defaults to `<rule name>.<format>`. If the format attribute is unset, use `<rule name>.pcf`. This flag is mutually exclusive with the `multiple_outputs` attribute.",
    ),
    "properties": attr.string_dict(
        doc = """Dictionary of name value pairs used to pass in PCL external properties
        See the Pcl docs: https://pages.github.pie.apple.com/pcl/main/current/language-reference/index.html#resources""",
    ),
    "executor": attr.string(
        default = "native",
        values = ["java", "native"],
        doc = "Pcl executor to be used. One of: `java`, `native` (default)",
    ),
    "jvm_flags": attr.string_list(
        doc = """Optional list of flags to pass to the java process running Pcl. Only used if `executor` is `java`""",
    ),
    "_pcl_cli": attr.label(
        allow_single_file = True,
        cfg = "exec",
        default = "//pcl:pcl_native_executable",
        executable = True,
    ),
    "_pcl_java_cli": attr.label(
        cfg = "exec",
        default = "//pcl:pcl_java_executable",
        executable = True,
    ),
    "_pcl_symlink_tool": attr.label(
        cfg = "exec",
        default = "//pcl/private/com/apple/federation/pcl/symlinks",
        executable = True,
    ),
}

def _pcl_run_impl(ctx):
    script, runfiles = _write_pcl_script(ctx, in_runfiles = False)

    if ctx.attr.out and ctx.attr.multiple_outputs:
        fail("pcl_run: Can't specify both `multiple_outputs` and `out` for target {}".format(ctx.label))

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

    result = ctx.actions.run(
        inputs = runfiles.files,
        outputs = outputs,
        executable = script,
        tools = [
            ctx.attr._pcl_java_cli[DefaultInfo].files_to_run if ctx.attr.executor == "java" else ctx.executable._pcl_cli,
            ctx.attr._pcl_symlink_tool[DefaultInfo].files_to_run,
        ],
        arguments = [script_output.path],
        mnemonic = "PclRun",
    )
    return [DefaultInfo(files = depset(outputs), runfiles = ctx.runfiles(outputs))]

pcl_run = rule(
    implementation = _pcl_run_impl,
    attrs = _PCL_RUN_ATTRS,
)

def _pcl_test_impl(ctx):
    """Test that a pcl file compiles without errors."""
    script, runfiles = _write_pcl_script(ctx, in_runfiles = True)
    return [DefaultInfo(executable = script, runfiles = runfiles)]

pcl_test = rule(
    implementation = _pcl_test_impl,
    attrs = _PCL_RUN_ATTRS,
    test = True,
)
