load(":providers.bzl", "PclFileInfo")

def _pcl_library_impl(ctx):
    src_files = ctx.files.srcs + ctx.files.data

    dep_files = depset(
        direct = src_files,
        transitive = [dep[PclFileInfo].dep_files for dep in ctx.attr.deps],
    )

    cache_entries = depset(
        transitive = [dep[PclFileInfo].cache_entries for dep in ctx.attr.deps] +
                     [src[PclFileInfo].cache_entries for src in ctx.attr.srcs if PclFileInfo in src],
    )

    return [
        DefaultInfo(
            files = depset(src_files),
        ),
        PclFileInfo(
            dep_files = dep_files,
            cache_entries = cache_entries,
        ),
        OutputGroupInfo(
            pcl_sources = depset(src_files, transitive = [dep_files]),
        ),
    ]

pcl_library = rule(
    _pcl_library_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = [".pcl"],
        ),
        "deps": attr.label_list(
            providers = [
                [PclFileInfo],
            ],
        ),
        "data": attr.label_list(
            allow_files = True,
            doc = "Files to make available in the filesystem when building this configuration. These can be accessed by relative path.",
        ),
    },
)
