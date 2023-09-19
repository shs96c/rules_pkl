def parse_pkl_dep(dep):
    # Split the fully qualified name by separating on colons
    parts = dep.split(":")

    if len(parts) < 2 or len(parts) > 3:
        fail("Expected fully qualifed Pkl dep: %s" % dep)

    return struct(
        dep = dep,
        repo = parts[0],
        module_name = parts[1],
        simple_name = parts[1].split(".")[-1],
        version = parts[2] if len(parts) == 3 else None,
    )

def _make_safe(string):
    return string.replace("-", "_").replace(".", "_")

def bazel_repo_name(pkl_dep):
    parsed = parse_pkl_dep(pkl_dep)
    return "__".join([parsed.repo, _make_safe(parsed.module_name), _make_safe(parsed.version)])

def generate_lock_hash(deps):
    return str(hash(repr(sorted(deps))))
