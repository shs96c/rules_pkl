# Pkl Rules

[Pkl][] is an embeddable configuration language with rich support for data templating and
validation. It can be used from the command line, integrated in a build pipeline, or embedded in a
program. Pkl scales from small to large, simple to complex, ad-hoc to repetitive configuration
tasks.

It can be used within Valentine to specify, verify configuration and to provide a well-defined
schema for configuration that can be shared across components. It can also be used to generate
configuration POJOs.

For further information about Pkl, check out the [official PKL documentation][].

[official PKL documentation]: https://pages.github.pie.apple.com/pkl/main/current
[pkl]: https://github.pie.apple.com/pkl/pkl

## Quick Start

### Setup

Add the following to your `WORKSPACE`:

```starlark
# Set up PKL rules.
load("@apple_federation//pkl:repositories.bzl", "pkl_deps")

pkl_deps()

load("@apple_federation//pkl:setup.bzl", "pkl_setup")

pkl_setup()

load("@apple_federation//pkl:workspace.bzl", "PKL_DEPS")

# Set up maven dependencies needed by PKL, only needed if you are using the PKL Java API.
# This is assuming you use @rules_jvm_external to manage your maven deps.
load("@apple_federation//java:repositories.bzl", "java_deps")

java_deps()

load("@apple_federation//java:setup.bzl", "java_setup")

java_setup()

load("@apple_federation//java:workspace.bzl", "maven_install")

maven_install(
    name = "maven-deps",
    artifacts = PKL_DEPS,
)
```

### Downloading from Pkl Hub

You can speed up builds that download modules from Pkl Hub by having Bazel download and cache
them for you before the builds are run. To do this, first of all edit your `WORKSPACE` file to
include the following after the call to `pkl_setup`:

```starlark
load("@apple_federation//pkl:workspace.bzl", "pkl_hub_deps")

pkl_hub_deps(
    name = "pkl_deps",
    deps = [
        # Deps listed here are the `Module URI` from Pkl Hub. Note that this
        # list only needs your first-order dependencies (that is, Pkl files
        # you depend on directly). The lock file will contain the transitive
        # entries too, and so will have many more entries.
        "applehub:com.apple.rio.Rio:705e2596",
    ],
)

load("@pkl_deps//:deps.bzl", "load_pkl_hub_deps")

load_pkl_hub_deps()
```

Once this is done, run `REPIN=1 bazel run @pkl_deps//:pin`. This will create a lock file, which
you can copy wherever you prefer, or you can just leave it in the default location. The lock file
is named after the `name` parameter in the `pkl_hub_deps` rule. You can now add the `lock_file`
attribute to the `pkl_hub_deps` you created above, using a `Label` to refer to the lock file. For
example, it may now read:

```starlark
pkl_hub_deps(
    name = "pkl_deps",
    deps = [
        # Deps listed here are the `Module URI` from Pkl Hub. Note that this
        # list only needs your first-order dependencies (that is, Pkl files
        # you depend on directly). The lock file will contain the transitive
        # entries too, and so will have many more entries.
        "applehub:com.apple.rio.Rio:705e2596",
    ],
    lock_file = "@//:pkl_deps_lock.json",
)
```

Whenever you add a new item to the `deps` attribute, you should run
`REPIN=1 bazel run @pkl_deps//:pin` again.

Now that Bazel knows about these Pkl Hub dependencies, you need to use them. This can be done
by editing a build file and using the `pkl_dep` macro. For example:

```starlark
# In a BUILD.bazel file
load("@apple_federation//pkl:defs.bzl", "pkl_library")
load("@pkl_deps//:defs.bzl", "pkl_dep")

pkl_library(
    name = "pkl_hub_dep",
    srcs = [
        "rio.pkl",
    ],
    deps = [
        # This allows access to any dependency listed in `pkl_hub_deps`
        "@pkl_deps//:all_deps",
    ],
)
```

You can see an example of this in action [within the Federation's
own test suite](../../../tests/general/pkl/pkl_hub_dep/BUILD.bazel)

### Using file generation rules

This is the equivalent of running the `pkl` CLI on the command line.

In your `BUILD.bazel` file:

```starlark
load("@apple_federation//pkl:defs.bzl", "pkl_test")

pkl_test(
    name = "my-config",
    srcs = [":config.pkl"],
)
```

See the `example/` directory for a complete example.

#### Using the Java API

- Define your configuration in a Pkl file:

  ```
  module com.apple.com.app.config.myModule

  class MyConfig {
      name: String
  }
  ```

- Export your configuration schema as a `filegroup` in a `BUILD` file:

  ```starlark
  filegroup(
      name = "my_config_schema",
      srcs = glob(["where/your/schema/is/*.pkl"]),
      visibility = [
          "//visibility:public",
      ]
  )
  ```

- (Optional) Define Java POJOs from your configuration schema in a `BUILD` file:

  ```starlark
  load("@apple_federation//pkl:defs.bzl", "pkl_config_java_library")

  pkl_config_java_library(
      name = "java_library_name",
      files=[
          "//path/to/your:config_schema
      ]
  )
  ```
