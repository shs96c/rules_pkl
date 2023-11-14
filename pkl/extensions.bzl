load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

def _toolchain_extension(module_ctx):
    http_file(
        name = "pkl-cli-macos",
        url = "https://artifacts.apple.com/artifactory/pcl-release-local/com/apple/pkl/pkl-cli-macos/0.24.6/pkl-cli-macos-0.24.6.bin",
        sha256 = "8f3a016b79796d63913afa9f56c3f91161bc3d6ae05ca7a63f8cc699b6c07654",
        executable = True,
    )

    http_file(
        name = "pkl-cli-linux-aarch64",
        url = "https://artifacts.apple.com/artifactory/pcl-release-local/com/apple/pkl/pkl-cli-linux-aarch64/0.24.6/pkl-cli-linux-aarch64-0.24.6.bin",
        sha256 = "7aae0eb3f9227ede086d34d687e720e1ce2df3b857d59bf2b69fb5896cb1c273",
        executable = True,
    )

    http_file(
        name = "pkl-cli-linux-x86_64",
        url = "https://artifacts.apple.com/artifactory/pcl-release-local/com/apple/pkl/pkl-cli-linux-amd64/0.24.6/pkl-cli-linux-amd64-0.24.6.bin",
        sha256 = "313465d132b838ca14c2090c5a26a643de899ef831c6155ef03407c450eeda8d",
        executable = True,
    )

pkl = module_extension(
    implementation = _toolchain_extension,
    tag_classes = {},
)
