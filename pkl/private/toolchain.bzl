def _pkl_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        cli = ctx.executable.cli,
        cli_files_to_run = ctx.attr.cli[DefaultInfo].files_to_run,
        cli_default_runfiles = ctx.attr.cli[DefaultInfo].default_runfiles,
        symlink_tool = ctx.executable._symlink_tool,
        symlink_default_runfiles = ctx.attr._symlink_tool[DefaultInfo].default_runfiles,
        symlink_files_to_run = ctx.attr._symlink_tool[DefaultInfo].files_to_run,
        make_variables = platform_common.TemplateVariableInfo({
            "PKL_BIN": ctx.executable.cli.path,
        }),
    )

    return [toolchain_info]

pkl_toolchain = rule(
    _pkl_toolchain_impl,
    attrs = {
        "cli": attr.label(
            allow_single_file = True,
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
    all_runfiles = ctx.runfiles(files = [toolchain.cli_files_to_run.executable])
    all_runfiles = all_runfiles.merge(toolchain.cli_default_runfiles)
    return [
        toolchain,
        toolchain.make_variables,
        DefaultInfo(
            files = depset(
                [toolchain.cli],
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
