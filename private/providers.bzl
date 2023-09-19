PklCacheEntryInfo = provider(
    doc = "Represents an item that should be added to the on-disk Pkl cache",
    fields = {
        "file": "A `File` that will be the cache entry",
        "path": "The path of the `file` within Pkl's own cache",
    },
)

PklFileInfo = provider(
    doc = "A combination of base Pkl files (from `pkl_library`) and cache entries, required to evaluate `pkl_run` rules",
    fields = {
        "dep_files": "Depset of the transitive closure of Pkl files and their dependencies",
        "cache_entries": "Depset of `PklCacheEntryInfo`",
    },
)
