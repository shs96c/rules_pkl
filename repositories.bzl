load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file", "http_jar")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//internal:utils.bzl", "check_import_ordering")
load("//common:repositories.bzl", "common_deps")
load("//internal/repositories/rules_jvm_external:repositories.bzl", "rules_jvm_external")

_DEFAULT_PKL_VERSION = "0.23.3"

_DOWNLOAD_URL = ("https://artifacts.apple.com/libs-release/com/apple/pkl/pkl-cli-{os}/{version}/pkl-cli-{os}-{version}.{ext}")

# We use the alpine versions as they are statically linked

# Note: when we delete 0.17.0 and before, we can switch the codegen and
# docs tool to use `pkl-tools`, and that will avoid dragging kotlin into
# the exported PKL_DEPS

_PKL_VERSIONS = {
    "0.16.0": {
        "pkl_linux": {
            "url": _DOWNLOAD_URL.format(version = "0.16.0", os = "alpine", ext = "bin"),
            "sha256": "2b5b8a6004e58961bb9d65f4f620a7f0111f634d57f109f348b2f51b70d6a78f",
        },
        "pkl_mac": {
            "url": _DOWNLOAD_URL.format(version = "0.16.0", os = "macos", ext = "bin"),
            "sha256": "fc165d0196a643ebcbf18d2db725fdbb3c4fa8ff6afe7cb81075b772eb83668f",
        },
        "pkl_java": {
            "url": _DOWNLOAD_URL.format(version = "0.16.0", os = "java", ext = "jar"),
            "sha256": "1e27e27169101421e9232d736f9e1e8bebf7efff1086b85d1995dc49dcb6f7e4",
        },
        "java_deps": [
            "com.apple.pkl:pkl-apple:0.16.0",
            "com.apple.pkl:pkl-doc:0.16.0",
            "com.apple.pkl:pkl-codegen-java:0.16.0",
            "com.apple.pkl:pkl-config-java:0.16.0",
        ],
    },
    "0.17.0": {
        "pkl_linux": {
            "url": _DOWNLOAD_URL.format(version = "0.17.0", os = "alpine", ext = "bin"),
            "sha256": "4c67dba3e39ea309c0c9e528d37248064c51da4a922ef720e52f2d4039b3c5b6",
        },
        "pkl_mac": {
            "url": _DOWNLOAD_URL.format(version = "0.17.0", os = "macos", ext = "bin"),
            "sha256": "cce38d1e2e87f3ad8026bcef04493ef6b091238a28e13824dc471ee38f523801",
        },
        "pkl_java": {
            "url": _DOWNLOAD_URL.format(version = "0.17.0", os = "java", ext = "jar"),
            "sha256": "d7ab6db9297fff2cf14a5e9a32d280b1b7e670ced0e1d579dfc4b618eddf368d",
        },
        "java_deps": [
            "com.apple.pkl:pkl-apple:0.17.0",
            "com.apple.pkl:pkl-doc:0.17.0",
            "com.apple.pkl:pkl-codegen-java:0.17.0",
            "com.apple.pkl:pkl-config-java:0.17.0",
        ],
    },
    "0.18.0": {
        "pkl_linux": {
            "url": _DOWNLOAD_URL.format(version = "0.18.0", os = "alpine", ext = "bin"),
            "sha256": "744256b3bd13407f6ebe18f095a66bcdf1abff83f7c4d21992acfe98968ea93c",
        },
        "pkl_mac": {
            "url": _DOWNLOAD_URL.format(version = "0.18.0", os = "macos", ext = "bin"),
            "sha256": "bd8e76de39775a742849205b911fb136c99dd1e746ad652b34dd8f884ac4e70b",
        },
        "pkl_java": {
            "url": _DOWNLOAD_URL.format(version = "0.18.0", os = "java", ext = "jar"),
            "sha256": "4bd0b353e0ef233354b51b2718109d3d0091a67f39a166213aa72f077c00b26d",
        },
        "java_deps": [
            "com.apple.pkl:pkl-apple:0.18.0",
            "com.apple.pkl:pkl-doc:0.18.0",
            "com.apple.pkl:pkl-codegen-java:0.18.0",
            "com.apple.pkl:pkl-config-java:0.18.0",
        ],
    },
    "0.19.2": {
        "pkl_linux": {
            "url": _DOWNLOAD_URL.format(version = "0.19.2", os = "alpine", ext = "bin"),
            "sha256": "0cd70ae3475d10678e195072eb812ec1b25ec13c301733b70568f10c90c6fa81",
        },
        "pkl_mac": {
            "url": _DOWNLOAD_URL.format(version = "0.19.2", os = "macos", ext = "bin"),
            "sha256": "58ad61a5680fb2293b38254fbe9043a687eb24b91b46fe4fec9152be087a7581",
        },
        "pkl_java": {
            "url": _DOWNLOAD_URL.format(version = "0.19.2", os = "java", ext = "jar"),
            "sha256": "cb54f98691153dcb09fd520b4e33ab47abf508532b31778d7d2ed20a0aad21c0",
        },
        "java_deps": [
            "com.apple.pkl:pkl-apple:0.19.2",
            "com.apple.pkl:pkl-doc:0.19.2",
            "com.apple.pkl:pkl-codegen-java:0.19.2",
            "com.apple.pkl:pkl-config-java:0.19.2",
        ],
    },
    "0.20.0": {
        "pkl_linux": {
            "url": _DOWNLOAD_URL.format(version = "0.20.0", os = "alpine", ext = "bin"),
            "sha256": "b4a1e5ec6af9d4a2c7e8cb7c9eca8e1072f49ebd4e87b515eb88b70d19c9a228",
        },
        "pkl_mac": {
            "url": _DOWNLOAD_URL.format(version = "0.20.0", os = "macos", ext = "bin"),
            "sha256": "6eb3e831045a1134216d9db191954c9188f27f7e9c239195bf29425cd68397df",
        },
        "pkl_java": {
            "url": _DOWNLOAD_URL.format(version = "0.21.0", os = "java", ext = "jar"),
            "sha256": "fda55613fd9e1cf3e9fa58b6480777bd0253958d40169afd9eee8e2f6f6d740f",
        },
        "java_deps": [
            "com.apple.pkl:pkl-apple:0.20.0",
            "com.apple.pkl:pkl-doc:0.20.0",
            "com.apple.pkl:pkl-codegen-java:0.20.0",
            "com.apple.pkl:pkl-config-java:0.20.0",
            "com.apple.pkl:pkl-tools:0.20.0",
        ],
    },
    "0.21.0": {
        "pkl_linux": {
            "url": _DOWNLOAD_URL.format(version = "0.21.0", os = "alpine", ext = "bin"),
            "sha256": "838ed5ee643529584fd8f2312fe96f0e9951304d2ef12acdcab1cdfd4ec523ce",
        },
        "pkl_mac": {
            "url": _DOWNLOAD_URL.format(version = "0.21.0", os = "macos", ext = "bin"),
            "sha256": "894c9da0ab0af4ab5c0935c3daf7469b4c8d725a43977d1a0552d402609939b1",
        },
        "pkl_java": {
            "url": _DOWNLOAD_URL.format(version = "0.21.0", os = "java", ext = "jar"),
            "sha256": "fda55613fd9e1cf3e9fa58b6480777bd0253958d40169afd9eee8e2f6f6d740f",
        },
        "java_deps": [
            "com.apple.pkl:pkl-apple:0.21.0",
            "com.apple.pkl:pkl-doc:0.21.0",
            "com.apple.pkl:pkl-codegen-java:0.21.0",
            "com.apple.pkl:pkl-config-java:0.21.0",
            "com.apple.pkl:pkl-tools:0.21.0",
        ],
    },
    "0.22.2": {
        "pkl_linux": {
            "url": _DOWNLOAD_URL.format(version = "0.22.2", os = "alpine-amd64", ext = "bin"),
            "sha256": "753eec1c0e0e234bbe1cf3338a03b5fc971bc23b5b40a4f4c4098e259e3e9d62",
        },
        "pkl_mac": {
            "url": _DOWNLOAD_URL.format(version = "0.22.2", os = "macos", ext = "bin"),
            "sha256": "123a7214f69ac36c34abbd528687540ceb4458aa10826d16ba7129ba4823119c",
        },
        "pkl_java": {
            "url": _DOWNLOAD_URL.format(version = "0.22.2", os = "java", ext = "jar"),
            "sha256": "47f8f96001051baf8bb65becde16474a7a30418dd0b0b30a821bd386e5d36483",
        },
        "java_deps": [
            "com.apple.pkl:pkl-apple:0.22.2",
            "com.apple.pkl:pkl-doc:0.22.2",
            "com.apple.pkl:pkl-codegen-java:0.22.2",
            "com.apple.pkl:pkl-config-java:0.22.2",
            "com.apple.pkl:pkl-tools:0.22.2",
        ],
    },
    "0.23.3": {
        "pkl_linux": {
            "url": _DOWNLOAD_URL.format(version = "0.23.3", os = "alpine-amd64", ext = "bin"),
            "sha256": "41a2a0ae82c420362baa6a4ad235c1227aea3f4238b38a220bf1cc98875e0ec4",
        },
        "pkl_mac": {
            "url": _DOWNLOAD_URL.format(version = "0.23.3", os = "macos", ext = "bin"),
            "sha256": "7e652dbd8bd2bebed41e34c2d300484b2b11911bae4d5dbfceced08daf4a622e",
        },
        "pkl_java": {
            "url": _DOWNLOAD_URL.format(version = "0.23.3", os = "java", ext = "jar"),
            "sha256": "d2cf2767136b53785b21d62022317083290cad1a77b6b66729121248ebb094cd",
        },
        "java_deps": [
            "com.apple.pkl:pkl-apple:0.23.3",
            "com.apple.pkl:pkl-doc:0.23.3",
            "com.apple.pkl:pkl-codegen-java:0.23.3",
            "com.apple.pkl:pkl-config-java:0.23.3",
            "com.apple.pkl:pkl-tools:0.23.3",
        ],
    },
}

def _underscore(str):
    return str.replace(".", "_").replace("-", "_")

def _write_constants_impl(repository_ctx):
    version = _underscore(repository_ctx.attr.version)

    repository_ctx.file(
        "BUILD.bazel",
        content = """
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("@bazel_skylib//rules:copy_file.bzl", "copy_file")

bzl_library(
    name = "docs",
    srcs = ["constants.bzl"],
    visibility = ["//visibility:public"],
)

copy_file(
    name = "pkl_native_executable",
    src = select(
        {{
            "@apple_federation//common/configs:linux": "@pkl_{version}_linux//file:downloaded",
            "@apple_federation//common/configs:macos": "@pkl_{version}_macos//file:downloaded",
        }},
    ),
    out = "pkl",
    allow_symlink = True,
    is_executable = True,
    visibility = ["//visibility:public"],
)
        """.format(version = version),
    )

    repository_ctx.file(
        "constants.bzl",
        content = "PKL_VERSION = {version}\nPKL_DEPS = {deps}\n".format(
            version = repr(repository_ctx.attr.version),
            deps = repository_ctx.attr.java_deps,
        ),
    )

_write_constants = repository_rule(
    _write_constants_impl,
    attrs = {
        "java_deps": attr.string(),
        "version": attr.string(),
    },
)

def pkl_deps(version = _DEFAULT_PKL_VERSION):
    """Pull in extra dependencies required by Pkl.

    Args:
      version: The version of Pkl to use (defaults to %s)""" % _DEFAULT_PKL_VERSION

    check_import_ordering(
        check_ruleset = "pkl_constants",
        federation_ruleset = "pkl_deps",
        known_conflicts = ["java_deps", "rio_deps"],
    )
    ruleset_pkl_deps(version)

def ruleset_pkl_deps(version = _DEFAULT_PKL_VERSION):
    """Internal to the Federation; please do not call"""

    if native.existing_rule("pkl_constants"):
        # We've already been initialized, so assume that everything is fine
        return

    common_deps()

    # We need this for the artifact macro. We'd like to use //java:repositories.bzl
    # directly, but we can't as this introduces a cycle. Since we need just the
    # one definition, this _should_ be okay.
    rules_jvm_external()

    if not version in _PKL_VERSIONS.keys():
        fail("Unknown Pkl version. Supported versions are: %s" % ", ".join(_PKL_VERSIONS.keys()))

    version_deps = _PKL_VERSIONS[version]

    pkl_linux = version_deps["pkl_linux"]
    maybe(
        http_file,
        name = "pkl_%s_linux" % _underscore(version),
        sha256 = pkl_linux["sha256"],
        urls = [
            pkl_linux["url"],
        ],
        executable = True,
    )

    pkl_mac = version_deps["pkl_mac"]
    maybe(
        http_file,
        name = "pkl_%s_macos" % _underscore(version),
        sha256 = pkl_mac["sha256"],
        urls = [
            pkl_mac["url"],
        ],
        executable = True,
    )

    pkl_java = version_deps["pkl_java"]
    maybe(
        http_jar,
        name = "pkl_java",
        sha256 = pkl_java["sha256"],
        urls = [
            pkl_java["url"],
        ],
    )

    # Write the constants into a temporary workspace so we can refer to them later
    maybe(
        _write_constants,
        name = "pkl_constants",
        version = version,
        java_deps = repr(version_deps["java_deps"]),
    )
