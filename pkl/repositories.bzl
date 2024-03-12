load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@rules_jvm_external//:defs.bzl", "maven_install")
load("//pkl/private:constants.bzl", "PKL_DEPS")

def pkl_cli_binaries():
    maybe(
        http_file,
        name = "pkl-cli-macos",
        url = "https://artifacts.apple.com/artifactory/pcl-release-local/com/apple/pkl/pkl-cli-macos/0.24.6/pkl-cli-macos-0.24.6.bin",
        sha256 = "8f3a016b79796d63913afa9f56c3f91161bc3d6ae05ca7a63f8cc699b6c07654",
        executable = True,
    )

    maybe(
        http_file,
        name = "pkl-cli-linux-arm64",
        url = "https://artifacts.apple.com/artifactory/pcl-release-local/com/apple/pkl/pkl-cli-linux-aarch64/0.24.6/pkl-cli-linux-aarch64-0.24.6.bin",
        sha256 = "7aae0eb3f9227ede086d34d687e720e1ce2df3b857d59bf2b69fb5896cb1c273",
        executable = True,
    )

    maybe(
        http_file,
        name = "pkl-cli-linux-x86_64",
        url = "https://artifacts.apple.com/artifactory/pcl-release-local/com/apple/pkl/pkl-cli-linux-amd64/0.24.6/pkl-cli-linux-amd64-0.24.6.bin",
        sha256 = "313465d132b838ca14c2090c5a26a643de899ef831c6155ef03407c450eeda8d",
        executable = True,
    )

    maybe(
        http_file,
        name = "pkl-cli-java",
        url = "https://artifacts.apple.com/artifactory/pcl-release-local/com/apple/pkl/pkl-cli-java/0.24.6/pkl-cli-java-0.24.6.jar",
        sha256 = "c279c9c7b0d87843a75794bca52f9e5dae2614796cff47a08dce24c029492e72",
        executable = True,
    )

def pkl_setup():
    pkl_cli_binaries()

    maven_install(
        name = "rules_pkl_deps",
        artifacts = PKL_DEPS,
        repositories = [
            "https://artifacts.apple.com/libs-release",
        ],
    )
