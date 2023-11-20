load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load("//pkl:repositories.bzl", "pkl_cli_binaries")

def _toolchain_extension(module_ctx):
    pkl_cli_binaries()

pkl = module_extension(
    implementation = _toolchain_extension,
    tag_classes = {},
)
