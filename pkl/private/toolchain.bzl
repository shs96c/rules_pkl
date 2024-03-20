"""
Implementation of toolchains for Pkl.
"""

def _pkl_toolchain_impl(ctx):
    all_runfiles = ctx.runfiles(files = [ctx.attr.cli[DefaultInfo].files_to_run.executable])
    all_runfiles = all_runfiles.merge(ctx.attr.cli[DefaultInfo].default_runfiles)
    default_info = DefaultInfo(
        files = depset(
            transitive = [ctx.attr.cli[DefaultInfo].files],
        ),
        runfiles = all_runfiles,
    )

    make_variables = platform_common.TemplateVariableInfo({
        "PKL_BIN": ctx.executable.cli.path,
    })
    toolchain_info = platform_common.ToolchainInfo(
        cli = ctx.attr.cli,
        default_info = default_info,
        make_variables = make_variables,
        symlink_tool = ctx.attr._symlink_tool,
    )

    return [
        default_info,
        make_variables,
        toolchain_info,
    ]

pkl_toolchain = rule(
    _pkl_toolchain_impl,
    attrs = {
        "cli": attr.label(
            executable = True,
            cfg = "exec",
        ),
        "_symlink_tool": attr.label(
            cfg = "exec",
            default = "//pkl/private/org/pkl_lang/bazel/symlinks",
            executable = True,
        ),
    },
)

def _pkl_codegen_java_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        codegen_cli = ctx.executable.cli,
        cli_files_to_run = ctx.attr.cli[DefaultInfo].files_to_run,
    )
    return [toolchain_info]

pkl_codegen_java_toolchain = rule(
    _pkl_codegen_java_toolchain_impl,
    attrs = {
        "cli": attr.label(
            default = "//pkl:pkl_codegen_cli",
            executable = True,
            cfg = "exec",
        ),
    },
)

def _pkl_doc_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        pkl_doc_cli = ctx.executable.cli,
    )
    return [toolchain_info]

pkl_doc_toolchain = rule(
    _pkl_doc_toolchain_impl,
    attrs = {
        "cli": attr.label(
            cfg = "exec",
            default = "//pkl:pkl_doc_cli",
            executable = True,
        ),
    },
)

def _current_pkl_toolchain_impl(ctx):
    toolchain = ctx.toolchains[str(Label("//pkl:toolchain_type"))]
    all_runfiles = ctx.runfiles(files = [toolchain.cli[DefaultInfo].files_to_run.executable])
    all_runfiles = all_runfiles.merge(toolchain.cli[DefaultInfo].default_runfiles)
    return [
        toolchain,
        toolchain.make_variables,
        DefaultInfo(
            files = depset(
                transitive = [toolchain.cli[DefaultInfo].files],
            ),
            runfiles = all_runfiles,
        ),
    ]

current_pkl_toolchain = rule(
    _current_pkl_toolchain_impl,
    toolchains = [
        "//pkl:toolchain_type",
    ],
)
