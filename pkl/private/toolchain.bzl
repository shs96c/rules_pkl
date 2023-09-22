def _pkl_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        cli = ctx.executable.cli,
        cli_files_to_run = ctx.attr.cli[DefaultInfo].files_to_run,
        symlink_tool = ctx.executable._symlink_tool,
        symlink_files_to_run = ctx.attr._symlink_tool[DefaultInfo].files_to_run,
    )

    return [toolchain_info]

pkl_toolchain = rule(
    _pkl_toolchain_impl,
    attrs = {
        "cli": attr.label(
            allow_single_file = True,
            default = "//pkl:pkl_cli",
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
