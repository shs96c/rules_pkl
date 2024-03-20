"""
Definition for Pkl Providers.
"""

PklFileInfo = provider(
    doc = "A combination of base Pkl files (from `pkl_library`) and cache entries, required to evaluate `pkl_eval` rules",
    fields = {
        "dep_files": "Depset of the transitive closure of Pkl files and their dependencies",
        "caches": "Depset of `PklCacheInfo`. When executing Pkl commands, there must be at most one item in this depset",
    },
)

PklCacheInfo = provider(
    doc = "A provider of a cache used by Pkl rules",
    fields = {
        "root": "A `File` representing the root of the cache",
        "label": "The `Label` of the rule that produced this cache info",
        "pkl_project": "A `File` representing the PklProjet that this cache was created from. Used for mapping shortnames to cache entries.",
        "pkl_project_deps": "A `File` representing the PklProjet.deps.json that this cache was created from.",
    },
)
