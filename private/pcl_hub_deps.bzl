load(":utils.bzl", "bazel_repo_name", "generate_lock_hash", "parse_pcl_dep")

def _read_deps_from_lock_file(rctx):
    raw = rctx.read(rctx.path(rctx.attr.lock_file))
    lock = json.decode(raw)

    expected_hash = generate_lock_hash(rctx.attr.deps)
    actual_hash = lock.get("hash")

    if expected_hash != actual_hash:
        env_vars = rctx.os.environ.keys()

        message = "Expected hash for dependencies (%s) is different from in lock file (%s). Please run `REPIN=1 @%s//:pin`" % (expected_hash, actual_hash, rctx.name)

        if not "REPIN" in env_vars and not "REPIN_PCL" in env_vars:
            fail(message)
        print(message)

    modules = []
    for (module, sha256) in lock.get("modules", {}).items():
        modules.append({
            "name": module,
            "sha256": sha256,
        })
    return modules

def _generate_deps_magically(rctx):
    # TODO: shell out to the generator and use that
    modules = []
    for module in rctx.attr.deps:
        modules.append({"name": module, "sha256": None})
    return modules

def _generate_deps_file(repos, modules):
    deps_content = """
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

def load_pcl_hub_deps():
"""

    for module in modules:
        parsed = parse_pcl_dep(module["name"])

        repo = repos.get(parsed.repo)

        # Figure out the URL
        url = "{repo}{module_name}/{version}/{simple_name}-{version}.pcl".format(
            repo = repo,
            module_name = parsed.module_name,
            simple_name = parsed.simple_name,
            version = parsed.version,
        )

        repo_name = bazel_repo_name(module["name"])

        # Indentation matters here because we're in the middle of the
        # `load_pcl_hub_deps` function
        deps_content += """
    http_file(
        name = "{name}",
        url = "{url}",
        sha256 = {sha256},
    )

""".format(
            name = repo_name,
            url = url,
            sha256 = repr(module["sha256"]),
        )

    # If there are no deps, then we still need to make sure that there's an indented block
    deps_content += "    pass"

    return deps_content

def _generate_build_file(name, raw_deps, repos, lock_file_path, modules):
    build_file_content = """
load("@apple_federation//pcl/private:pcl_library.bzl", "pcl_library")
load("@apple_federation//pcl/private:pcl_cache_entry.bzl", "pcl_cache_entry")
load("@apple_federation//pcl/private:pcl_pin.bzl", "pcl_pin")

"""

    all_modules = []
    for module in modules:
        parsed = parse_pcl_dep(module["name"])

        repo_name = bazel_repo_name(module["name"])
        all_modules.append(":%s" % repo_name)

        # Only make the modules that people asked for visible
        visibility = ["//visibility:public"] if module["name"] in raw_deps else None

        build_file_content += """
pcl_cache_entry(
    name = "{name}",
    repo_name = "{repo_name}",
    module_name = "{module_name}",
    version = "{version}",
    target = "{target}",
)

""".format(
            name = repo_name,  # yes, yes. I know
            module_name = parsed.module_name,
            repo_name = parsed.repo,
            target = "@%s//file" % repo_name,
            version = parsed.version,
        )

    build_file_content += """
pcl_library(
    name = "all_deps",
    srcs = [],
    deps = {deps},
    visibility = ["//visibility:public"],
)

""".format(
        deps = repr(all_modules),
    )

    build_file_content += """
pcl_pin(
    name = "pin",
    repo_name = {name},
    deps = {deps},
    repositories = {repos},
    lock_file = {lock_file},
)
""".format(
        deps = repr(raw_deps),
        lock_file = repr(lock_file_path),
        name = repr(name),
        repos = repr(repos),
    )

    return build_file_content

def _validate_deps(repos, deps):
    for dep in deps:
        parsed = parse_pcl_dep(dep["name"])

        repo = repos.get(parsed.repo)
        if not repo:
            fail("Unknown repository %s, please add to the `repositories` attribute" % parsed.repo)

def _pcl_hub_deps_impl(rctx):
    if rctx.attr.lock_file:
        # Make sure that all deps are listed, even if we don't know the hashes
        deps = _read_deps_from_lock_file(rctx)
        lock_file_path = "%s/%s" % (rctx.attr.lock_file.package, rctx.attr.lock_file.name)
    else:
        deps = _generate_deps_magically(rctx)
        lock_file_path = "%s_lock.json" % rctx.name

    if rctx.attr.lock_file and rctx.attr.lock_file.workspace_name:
        fail("Lock file may only be in the current workspace: %s" % str(rctx.attr.lock_file))

    _validate_deps(rctx.attr.repositories, deps)

    rctx.file(
        "deps.bzl",
        content = _generate_deps_file(rctx.attr.repositories, deps),
        executable = False,
    )

    rctx.file(
        "BUILD.bazel",
        content = _generate_build_file(rctx.name, rctx.attr.deps, rctx.attr.repositories, lock_file_path, deps),
        executable = False,
    )

pcl_hub_deps = repository_rule(
    _pcl_hub_deps_impl,
    doc = """Used for caching items from Pcl Hub so they don't need to be downloaded by the Pcl binary.""",
    attrs = {
        "deps": attr.string_list(
            allow_empty = True,
            doc = "A list of Pcl \"module URI\"s.",
        ),
        "repositories": attr.string_dict(
            default = {
                "applehub": "https://artifacts.apple.com/pcl/",
            },
            doc = "A dict mapping Pcl Hub name (eg. `applehub`) to a base URL.",
        ),
        "lock_file": attr.label(
            allow_single_file = True,
            doc = "The lock file to use.",
        ),
    },
    environ = [
        "REPIN",
        "REPIN_PCL",
    ],
)
