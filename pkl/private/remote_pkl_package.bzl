"""
Repository rule for downloading remote Pkl packages.
"""

load(":pkl_package_names.bzl", "get_terminal_package_name")

def _remote_pkl_package_impl(rctx):
    if not rctx.attr.url.startswith("projectpackage://"):
        fail("URL does not look like a Pkl project:", rctx.attr.url)

    url = rctx.attr.url.replace("projectpackage://", "https://")
    url_without_scheme = url.removeprefix("https://")

    file_name = get_terminal_package_name(url)

    # Grab the JSON from the original location
    rctx.download(url, sha256 = rctx.attr.sha256, output = "%s.json" % file_name)

    metadata = json.decode(rctx.read("%s.json" % file_name))
    rctx.download(metadata["packageZipUrl"], sha256 = metadata["packageZipChecksums"]["sha256"], output = "%s.zip" % file_name)

    rctx.file(
        "BUILD.bazel",
        content = """
load("@rules_pkl//pkl/private:pkl_cache.bzl", "pkl_cached_package")

package(default_visibility = ["//visibility:public"])

pkl_cached_package(
    name = "item",
    package_name = %s,
    json = %s,
    zip = %s,
)
""" % (repr(url_without_scheme), repr("%s.json" % file_name), repr("%s.zip" % file_name)),
    )

remote_pkl_package = repository_rule(
    _remote_pkl_package_impl,
    attrs = {
        "url": attr.string(),
        "sha256": attr.string(),
    },
)
