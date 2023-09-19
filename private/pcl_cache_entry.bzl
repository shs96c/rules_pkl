load(":providers.bzl", "PklCacheEntryInfo", "PklFileInfo")

def _pkl_cache_entry_impl(ctx):
    # Why is there a `-1` in the path? Because Pkl expects that to
    # be there in the on-disk cache, presumably for some kind of
    # future proofing.
    path = "{repo_name}-1/{module_name}/{version}/{simple_name}-{version}.pkl".format(
        repo_name = ctx.attr.repo_name,
        module_name = ctx.attr.module_name,
        simple_name = ctx.attr.module_name.split(".")[-1],
        version = ctx.attr.version,
    )

    return [
        DefaultInfo(
            files = depset([ctx.file.target]),
            runfiles = ctx.runfiles(files = [ctx.file.target]),
        ),
        PklFileInfo(
            dep_files = depset(),
            cache_entries = depset([
                PklCacheEntryInfo(
                    file = ctx.file.target,
                    path = path,
                ),
            ]),
        ),
    ]

pkl_cache_entry = rule(
    _pkl_cache_entry_impl,
    attrs = {
        "repo_name": attr.string(
            mandatory = True,
        ),
        "module_name": attr.string(
            mandatory = True,
        ),
        "version": attr.string(
            mandatory = True,
        ),
        "target": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
    },
)
