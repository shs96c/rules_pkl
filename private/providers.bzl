PclCacheEntryInfo = provider(
    doc = "Represents an item that should be added to the on-disk Pcl cache",
    fields = {
        "file": "A `File` that will be the cache entry",
        "path": "The path of the `file` within Pcl's own cache",
    },
)

PclFileInfo = provider(
    doc = "A combination of base Pcl files (from `pcl_library`) and cache entries, required to evaluate `pcl_run` rules",
    fields = {
        "dep_files": "Depset of the transitive closure of Pcl files and their dependencies",
        "cache_entries": "Depset of `PclCacheEntryInfo`",
    },
)
