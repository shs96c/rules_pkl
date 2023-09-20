def _toolchain_extension(module_ctx):
    pass

pkl = module_extension(
    implementation = _toolchain_extension,
    tag_classes = {},
)
