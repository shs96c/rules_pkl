def _pkl_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
    )

    return [toolchain_info]

pkl_toolchain = rule(
    _pkl_toolchain_impl,
    attrs = {
        cli: attr.label(
            allow_single_file = True,
            default = "@rules",
        ),
    },
)
