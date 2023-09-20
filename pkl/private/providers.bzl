PklFileInfo = provider(
    doc = "A combination of base Pkl files (from `pkl_library`) and cache entries, required to evaluate `pkl_run` rules",
    fields = {
        "dep_files": "Depset of the transitive closure of Pkl files and their dependencies",
        "cache_entries": "Depset of `PklCacheEntryInfo`",
    },
)
