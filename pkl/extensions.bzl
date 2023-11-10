load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

def _toolchain_extension(module_ctx):
    http_file(
        name = "pkl-cli-macos",
        sha256 = "c0662538905e8b37ed70619dd6bf64705ce22467bc050d91b8e55d83cba3a60c",
        urls = [
            "https://artifacts.apple.com/artifactory/pcl-modules-local/staging/com/apple/pkl/staging/pkl-cli-macos/0.24.5/pkl-cli-macos-0.24.5.bin",
        ],
        executable = True,
    )

    http_file(
        name = "pkl-cli-linux",
        sha256 = "c926141f978097aa7c66ae3ced2ca00578218f84025c26def8ec6335880bbeb4",
        urls = [
            "https://artifacts.apple.com/artifactory/pcl-modules-local/staging/com/apple/pkl/staging/pkl-cli-linux-aarch64/0.24.5/pkl-cli-linux-aarch64-0.24.5.bin",
        ],
        executable = True,
    )

pkl = module_extension(
    implementation = _toolchain_extension,
    tag_classes = {},
)
