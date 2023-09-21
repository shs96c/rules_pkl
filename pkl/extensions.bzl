load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

def _toolchain_extension(module_ctx):
    http_file(
        name = "pkl-cli-macos",
        sha256 = "00e94ef981764bafb222a209d6d86bc3990b66597156cd803e0eaf5178a7f8e4",
        urls = [
            "https://artifacts.apple.com/artifactory/libs-release/com/apple/pkl/pkl-cli-macos/0.24.0/pkl-cli-macos-0.24.0.bin",
        ],
        executable = True,
    )

pkl = module_extension(
    implementation = _toolchain_extension,
    tag_classes = {},
)
