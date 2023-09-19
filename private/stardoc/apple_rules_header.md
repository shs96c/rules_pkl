# Apple-Provided Rules

These rules are developed and managed by Apple. To use them:

```starlark
# In your WORKSPACE
load("@apple_federation//pcl:repositories.bzl", "pcl_deps")

pcl_deps()

load("@apple_federation//pcl:setup.bzl", "pcl_setup")

pcl_setup()
```

Then, in a build file, you can use:

```starlark
load("@apple_federation//pcl:defs.bzl", "pcl_library")
```

