def _pkl_doc_impl(ctx):
    modules = [module.path for module in ctx.files.deps]

    # Generate HTML from Pkl

    outfile = ctx.outputs.out
    if outfile == None:
        outfile = ctx.actions.declare_file(ctx.label.name + "_docs.zip")

    outdir_path = outfile.path + ".tmpdir"
    command = "{executable} -o {output}".format(
        executable = ctx.executable._pkl_doc_cli.path,
        output = outdir_path,
    )
    if modules:
        command += " --module-path " + ctx.configuration.host_path_separator.join([module.path for module in modules])
    for file in ctx.files.srcs:
        command += " " + file.path

    # The zip binary only accepts files, not directories, so we need to do the `find` ourself.
    # Then we need to translate index.html into index.html=bazel-out/.../index.html to strip the bazel-out/... prefixes from the output zip.
    command += " && (cd {outdir} && find . -type f) | sed -e 's#^\\./\\(.*\\)$#\\1={outdir}/\\1#' | xargs {zip} cC {outfile}".format(
        zip = ctx.executable._zip.path,
        outfile = outfile.path,
        outdir = outdir_path,
    )

    ctx.actions.run_shell(
        command = command,
        inputs = ctx.files.deps + ctx.files.srcs,
        outputs = [outfile],
        tools = [ctx.executable._pkl_doc_cli, ctx.executable._zip],
        progress_message = "Generating Pkl docs",
    )

    return OutputGroupInfo(out = [outfile])

_pkl_doc = rule(
    _pkl_doc_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = [".pkl"],
        ),
        "deps": attr.label_list(
            mandatory = False,
            allow_files = [".pkl"],
        ),
        "out": attr.output(),
        "_pkl_doc_cli": attr.label(
            cfg = "exec",
            default = "//pkl:pkl_doc_cli",
            executable = True,
        ),
        "_zip": attr.label(
            allow_single_file = True,
            cfg = "exec",
            default = "@bazel_tools//tools/zip:zipper",
            executable = True,
        ),
    },
)

def pkl_doc(name, srcs, **kwargs):
    if "out" not in kwargs:
        kwargs["out"] = name + "_docs.zip"
    _pkl_doc(
        name = name,
        srcs = srcs,
        **kwargs
    )
