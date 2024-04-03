"""
Repository rules for defining dependencies.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@rules_jvm_external//:defs.bzl", "maven_install")
load("//pkl/private:constants.bzl", "PKL_DEPS")

def pkl_cli_binaries():
    maybe(
        http_file,
        name = "pkl-cli-macos-aarch64",
        url = "https://github.com/apple/pkl/releases/download/0.25.3/pkl-macos-aarch64",
        sha256 = "5a8efc3ab69ec96a6505ad6d0dd2ef6780319b0d0e65eee1872ad23fabb5ad5b",
        executable = True,
    )

    maybe(
        http_file,
        name = "pkl-cli-macos-x86_64",
        url = "https://github.com/apple/pkl/releases/download/0.25.3/pkl-macos-amd64",
        sha256 = "66916a9402e788d01056f5734239e8d2c5a0d0006d1ad45bf8a56abd1ca855c6",
        executable = True,
    )

    maybe(
        http_file,
        name = "pkl-cli-linux-aarch64",
        url = "https://github.com/apple/pkl/releases/download/0.25.3/pkl-linux-aarch64",
        sha256 = "5b77b88c15bfa41028da399eb5f3c01ed72a8ca4ea1f3ffe3bc1f56ec63a773b",
        executable = True,
    )

    maybe(
        http_file,
        name = "pkl-cli-linux-x86_64",
        url = "https://github.com/apple/pkl/releases/download/0.25.3/pkl-linux-amd64",
        sha256 = "fb2c8ad5de113a1246599e893492736b79e73bdf986ba4caf305cd09aae82c10",
        executable = True,
    )

def pkl_setup():
    pkl_cli_binaries()

    maven_install(
        name = "rules_pkl_deps",
        artifacts = PKL_DEPS,
        repositories = [
            "https://repo1.maven.org/maven2/",
        ],
    )
