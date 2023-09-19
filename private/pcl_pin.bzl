load(":utils.bzl", "generate_lock_hash")

def _pkl_pin_impl(ctx):
    hash = generate_lock_hash(ctx.attr.deps)

    params = {
        "deps": ctx.attr.deps,
        "hash": hash,
        "repos": ctx.attr.repositories,
    }

    # Inlining `encoded` does Bad Things
    encoded = json.encode_indent(params, indent = "  ")
    params = ctx.actions.declare_file("%s.params" % ctx.label.name)
    ctx.actions.write(params, content = encoded)

    script = ctx.actions.declare_file("%s.sh" % ctx.label.name)
    ctx.actions.write(
        script,
        content = """#!/usr/bin/env bash

set -eu

{generate_lock} {params} > "$BUILD_WORKSPACE_DIRECTORY/{lock_file}"

echo "Wrote Pkl deps to {lock_file}"
""".format(
            generate_lock = ctx.executable._generate_lock_file.short_path,
            params = params.short_path,
            lock_file = ctx.attr.lock_file,
        ),
    )

    # Gather all the inputs into our runfiles
    runfiles = ctx.runfiles(
        files = [
            params,
        ],
    ).merge(
        ctx.attr._generate_lock_file[DefaultInfo].default_runfiles,
    )

    return [
        DefaultInfo(
            executable = script,
            runfiles = runfiles,
        ),
    ]

pkl_pin = rule(
    _pkl_pin_impl,
    executable = True,
    attrs = {
        "repo_name": attr.string(),
        "deps": attr.string_list(
            allow_empty = True,
        ),
        "repositories": attr.string_dict(
            default = {
                "applehub": "https://artifacts.apple.com/pkl/",
            },
        ),
        "lock_file": attr.string(),
        "_generate_lock_file": attr.label(
            executable = True,
            cfg = "exec",
            default = "@apple_federation//pkl/private/com/apple/federation/pkl/locks:GenerateLock",
        ),
    },
)
