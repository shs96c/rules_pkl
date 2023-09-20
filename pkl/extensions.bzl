load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

def _toolchain_extension(module_ctx):
    http_file(
        name = "pkl-cli-macos",
        sha256 = "74d544d96f4a5bb630d465ca8bbcfe231e3594e5aae57e1edbf17a6eb3ca2506",
        urls = [
            "https://artifacts.apple.com/artifactory/libs-release/com/apple/pkl/pkl-cli-macos/0.24.0/pkl-cli-macos-0.24.0.bin",
        ],
    )

pkl = module_extension(
    implementation = _toolchain_extension,
    tag_classes = {},
)
