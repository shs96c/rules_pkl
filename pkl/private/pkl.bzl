load(":providers.bzl", "PklFileInfo")

def _best_path(file):
    if file.is_source:
        # Files from the cache hit this code path. For them, the `path`
        # points to the path from the root of the repo (valid from where
        # we run the scripts), but `short_path` starts with `../` and so
        # points to nowhere when we finally merge things
        return file.path
    else:
        # But files that aren't sources will have the correct short_path
        # already, so we can use that.
        return file.short_path

def _prepare_pkl_script(ctx, command):
    pkl_toolchain = ctx.toolchains["//pkl:toolchain_type"]

    executable = pkl_toolchain.cli[DefaultInfo].files_to_run.executable

    # Build a forest of symlinks. Why do we need to this? It's because
    # when we execute the Pkl, the cache directory cannot be below the
    # working directory of the script because when Pkl searches for
    # dependencies, it effectively does a glob of the current working
    # directory, and if the cache is there then denormalised dependency
    # URIs won't resolve properly.
    working_dir = "%s/work" % ctx.label.name

    # A map of {file: path_to_pkl_in_symlinks}
    symlinks = {}
    all_files = depset(transitive = [f[DefaultInfo].files for f in ctx.attr.srcs + ctx.attr.deps + ctx.attr.data]).to_list()
    for file in all_files:
        symlinks[file] = "%s/%s" % (working_dir, file.short_path)

    file_infos = [dep[PklFileInfo] for dep in ctx.attr.srcs + ctx.attr.deps if PklFileInfo in dep]
    caches = depset(transitive = [i.caches for i in file_infos]).to_list()

    if len(caches) > 1:
        cache_labels = [c.label for c in caches]
        fail("Only one cache item is allowed. The following labels of caches were seen: ", cache_labels)

    for info in file_infos:
        for file in info.dep_files.to_list():
            symlinks[file] = "%s/%s" % (working_dir, file.short_path)

    # Mangle symlinks
    path_to_symlink_target = {}
    for file, path in symlinks.items():
        path_to_symlink_target[_best_path(file)] = path
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

    if len(caches):
        path_to_symlink_target[caches[0].pkl_project.path] = "%s/PklProject" % working_dir
        path_to_symlink_target[caches[0].pkl_project_deps.path] = "%s/PklProject.deps.json" % working_dir
        path_to_symlink_target[caches[0].root.path] = "%s/cache" % ctx.label.name

    symlinks_json_file = ctx.actions.declare_file(ctx.label.name + "_symlinks.json")
    ctx.actions.write(output = symlinks_json_file, content = json.encode(path_to_symlink_target))
    pkl_symlink_tool = pkl_toolchain.symlink_tool

    # The 'run_args' and 'test_args' need to be separate to support '--experimental_output_path=strip' until the following
    # upstream PR is merged (https://github.com/bazelbuild/bazel/pull/16430) as Bazel only performs path stripping on paths in
    # 'ctx.Args' object, which can't be used in test actions.
    common_args = [
        "--format {}".format(ctx.attr.format) if ctx.attr.format else "",
        " ".join([f.path for f in (ctx.files.entrypoints or ctx.files.srcs)]),
        ctx.attr.multiple_outputs,
        working_dir,
        command,
    ]

    run_args = common_args + [
        executable,
        symlinks_json_file,
        pkl_symlink_tool[DefaultInfo].files_to_run.executable.path,
    ]

    test_args = common_args + [
        executable.short_path,
        symlinks_json_file.short_path,
        pkl_symlink_tool[DefaultInfo].files_to_run.executable.short_path,
    ]

    for k, v in ctx.attr.properties.items():
        property_flag = ["--property", "{}={}".format(k, ctx.expand_location(v, ctx.attr.data))]
        run_args += property_flag
        test_args += property_flag

    if getattr(ctx.attr, "expression"):
        expression_flag = ["-x", ctx.attr.expression]
        run_args += expression_flag
        test_args += expression_flag

    script = ctx.executable._pkl_script

    dep_files = [
        pkl_toolchain.cli[DefaultInfo].files,
        pkl_toolchain.symlink_tool[DefaultInfo].files,
    ]
    for dep in ctx.attr.deps:
        dep_files += [dep.files, dep[PklFileInfo].dep_files]

    if len(ctx.files.srcs) + len(dep_files) == 0:
        fail("{}: Cannot run pkl with no srcs or deps".format(ctx.label))

    for dep in ctx.attr.data:
        dep_files.append(dep[DefaultInfo].files)

    direct_files = [script, symlinks_json_file] + symlinks.keys()
    if len(caches):
        direct_files += [caches[0].root, caches[0].pkl_project, caches[0].pkl_project_deps]

    runfiles = ctx.runfiles(
        files = direct_files + [
            pkl_toolchain.cli[DefaultInfo].files_to_run.executable,
            pkl_toolchain.symlink_tool[DefaultInfo].files_to_run.executable,
        ],
        transitive_files = depset(
            transitive = [pkl_toolchain.cli[DefaultInfo].files, pkl_toolchain.symlink_tool[DefaultInfo].files] + dep_files,
        ),
    ).merge(
        pkl_toolchain.symlink_tool[DefaultInfo].default_runfiles,
    ).merge(
        pkl_toolchain.cli[DefaultInfo].default_runfiles,
    )
    return script, runfiles, run_args, test_args

_PKL_EVAL_ATTRS = {
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
        doc = """Whether to expect to render multiple file outputs. If `outs` is specified then individual generated files will
        be exposed. Otherwise, a single directory, with the name of the target, containing all generated files will be exposed.
        (see https://pkl.apple.com/main/current/language-reference/index.html#multiple-file-output).""",
    ),
    "outs": attr.string_list(
        doc = "Name of the output file to generate. Defaults to `<rule name>.<format>`. If the format attribute is unset, use `<rule name>.pcf`. Expects a single file if `multiple_outputs` is not set to `True`.",
    ),
    "properties": attr.string_dict(
        doc = """Dictionary of name value pairs used to pass in PKL external properties
            See the Pkl docs: https://pages.github.pie.apple.com/pkl/main/current/language-reference/index.html#resources""",
    ),
    "_pkl_script": attr.label(
        default = "//pkl/private:run_pkl_script",
        executable = True,
        cfg = "exec",
    ),
}

def _pkl_eval_impl(ctx):
    script, runfiles, run_args, _ = _prepare_pkl_script(ctx, command = "eval")
    if not ctx.attr.multiple_outputs and len(ctx.attr.outs) > 1:
        fail("expecting single output file, however {outputs_count} outputs have been specified. Set `multiple_outputs=True` if expecting multiple outputs."
            .format(outputs_count = len(ctx.attr.outs)))

    outputs = []
    output_location = ""

    # if `multiple_outputs`== true && `outs` is specified, then individual generated files listed in `outs` are created.
    # if `multiple_outputs`== true && `outs` is NOT specified, then a single directory of generated files is created.
    # if `multiple_outputs`== false && `outs` is specified, then the single file listed in `outs` is created.
    # if `multiple_outputs`== true && `outs` is NOT specified, then a file named with the target's label is created.

    if ctx.attr.multiple_outputs:
        if len(ctx.attr.outs) > 0:
            for output_name in ctx.attr.outs:
                relative_path = "{}/{}".format(ctx.label.name, output_name)
                outputs.append(ctx.actions.declare_file(relative_path))
            output_location = outputs[0].path.removesuffix(ctx.attr.outs[0])
        else:
            output_location = ctx.actions.declare_directory(ctx.label.name)
            outputs.append(output_location)
    else:
        output_format = ctx.attr.format or "pcf"
        filename = ctx.attr.outs[0] if len(ctx.attr.outs) > 0 else "{}.{}".format(ctx.label.name, output_format)
        relative_path = "{}/{}".format(ctx.label.name, filename)
        output_location = ctx.actions.declare_file(relative_path)
        outputs.append(output_location)

    pkl_toolchain = ctx.toolchains["//pkl:toolchain_type"]

    is_test = "false"
    args = ctx.actions.args()
    args.add_all(
        [output_location, is_test] + run_args,
        expand_directories = False,
    )

    result = ctx.actions.run(
        inputs = runfiles.files,
        outputs = outputs,
        executable = script,
        tools = [
            pkl_toolchain.cli[DefaultInfo].files_to_run,
            pkl_toolchain.symlink_tool[DefaultInfo].files_to_run,
        ],
        arguments = [args],
        mnemonic = "PklRun",
        execution_requirements = {
            "supports-path-mapping": "1",
        },
    )
    return [DefaultInfo(files = depset(outputs), runfiles = ctx.runfiles(outputs))]

pkl_eval = rule(
    _pkl_eval_impl,
    attrs = _PKL_EVAL_ATTRS,
    toolchains = [
        "//pkl:toolchain_type",
    ],
)

def _pkl_test_impl(ctx):
    script, runfiles, _, test_args = _prepare_pkl_script(ctx, command = "test")

    output_script = ctx.actions.declare_file(ctx.label.name + ".sh")

    is_test = "true"
    test_args = [output_script.path, is_test] + test_args
    args_str = " ".join(["'{}'".format(str(a).replace("'", "\\'")) for a in test_args])

    cmd = """#!/usr/bin/env bash
{script} {args}
""".format(
        script = script.short_path,
        args = args_str,
    )

    ctx.actions.write(
        output = output_script,
        content = cmd,
        is_executable = True,
    )

    runfiles = runfiles.merge(ctx.runfiles(files = [script]))
    output_script = ctx.actions.declare_file(ctx.label.name + ".sh")

    return [DefaultInfo(executable = output_script, runfiles = runfiles)]

pkl_test = rule(
    implementation = _pkl_test_impl,
    attrs = _PKL_EVAL_ATTRS,
    test = True,
    toolchains = [
        "//pkl:toolchain_type",
    ],
)
