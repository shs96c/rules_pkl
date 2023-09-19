# Apple-Provided Rules

These rules are developed and managed by Apple. To use them:

```starlark
# In your WORKSPACE
load("@apple_federation//pkl:repositories.bzl", "pkl_deps")

pkl_deps()

load("@apple_federation//pkl:setup.bzl", "pkl_setup")

pkl_setup()
```

Then, in a build file, you can use:

```starlark
load("@apple_federation//pkl:defs.bzl", "pkl_library")
```

