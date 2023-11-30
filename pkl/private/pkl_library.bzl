load(":providers.bzl", "PklFileInfo")

def _pkl_library_impl(ctx):
    src_files = ctx.files.srcs + ctx.files.data

    dep_files = depset(
        direct = src_files,
        transitive = [dep[PklFileInfo].dep_files for dep in ctx.attr.deps],
    )

    caches = depset(
        transitive = [dep[PklFileInfo].caches for dep in ctx.attr.deps] +
                     [src[PklFileInfo].caches for src in ctx.attr.srcs if PklFileInfo in src],
    )

    return [
        DefaultInfo(
            files = depset(src_files),
        ),
        PklFileInfo(
            dep_files = dep_files,
            caches = caches,
        ),
        OutputGroupInfo(
            pkl_sources = depset(src_files, transitive = [dep_files]),
        ),
    ]

pkl_library = rule(
    _pkl_library_impl,
    doc = "Collect Pkl sources together so they can be used by other `rules_pkl` rules.",
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = [".pkl"],
        ),
        "deps": attr.label_list(
            providers = [
                [PklFileInfo],
            ],
        ),
        "data": attr.label_list(
            allow_files = True,
            doc = "Files to make available in the filesystem when building this configuration. These can be accessed by relative path.",
        ),
    },
)
