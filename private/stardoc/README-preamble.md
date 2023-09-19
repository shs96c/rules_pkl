# Pcl Rules

[Pcl][] is an embeddable configuration language with rich support for data templating and
validation. It can be used from the command line, integrated in a build pipeline, or embedded in a
program. Pcl scales from small to large, simple to complex, ad-hoc to repetitive configuration
tasks.

It can be used within Valentine to specify, verify configuration and to provide a well-defined
schema for configuration that can be shared across components. It can also be used to generate
configuration POJOs.

For further information about Pcl, check out the [official PCL documentation][].

[official PCL documentation]: https://pages.github.pie.apple.com/pcl/main/current
[pcl]: https://github.pie.apple.com/pcl/pcl

## Quick Start

### Setup

Add the following to your `WORKSPACE`:

```starlark
# Set up PCL rules.
load("@apple_federation//pcl:repositories.bzl", "pcl_deps")

pcl_deps()

load("@apple_federation//pcl:setup.bzl", "pcl_setup")

pcl_setup()

load("@apple_federation//pcl:workspace.bzl", "PCL_DEPS")

# Set up maven dependencies needed by PCL, only needed if you are using the PCL Java API.
# This is assuming you use @rules_jvm_external to manage your maven deps.
load("@apple_federation//java:repositories.bzl", "java_deps")

java_deps()

load("@apple_federation//java:setup.bzl", "java_setup")

java_setup()

load("@apple_federation//java:workspace.bzl", "maven_install")

maven_install(
    name = "maven-deps",
    artifacts = PCL_DEPS,
)
```

### Downloading from Pcl Hub

You can speed up builds that download modules from Pcl Hub by having Bazel download and cache
them for you before the builds are run. To do this, first of all edit your `WORKSPACE` file to
include the following after the call to `pcl_setup`:

```starlark
load("@apple_federation//pcl:workspace.bzl", "pcl_hub_deps")

pcl_hub_deps(
    name = "pcl_deps",
    deps = [
        # Deps listed here are the `Module URI` from Pcl Hub. Note that this
        # list only needs your first-order dependencies (that is, Pcl files
        # you depend on directly). The lock file will contain the transitive
        # entries too, and so will have many more entries.
        "applehub:com.apple.rio.Rio:705e2596",
    ],
)

load("@pcl_deps//:deps.bzl", "load_pcl_hub_deps")

load_pcl_hub_deps()
```

Once this is done, run `REPIN=1 bazel run @pcl_deps//:pin`. This will create a lock file, which
you can copy wherever you prefer, or you can just leave it in the default location. The lock file
is named after the `name` parameter in the `pcl_hub_deps` rule. You can now add the `lock_file`
attribute to the `pcl_hub_deps` you created above, using a `Label` to refer to the lock file. For
example, it may now read:

```starlark
pcl_hub_deps(
    name = "pcl_deps",
    deps = [
        # Deps listed here are the `Module URI` from Pcl Hub. Note that this
        # list only needs your first-order dependencies (that is, Pcl files
        # you depend on directly). The lock file will contain the transitive
        # entries too, and so will have many more entries.
        "applehub:com.apple.rio.Rio:705e2596",
    ],
    lock_file = "@//:pcl_deps_lock.json",
)
```

Whenever you add a new item to the `deps` attribute, you should run
`REPIN=1 bazel run @pcl_deps//:pin` again.

Now that Bazel knows about these Pcl Hub dependencies, you need to use them. This can be done
by editing a build file and using the `pcl_dep` macro. For example:

```starlark
# In a BUILD.bazel file
load("@apple_federation//pcl:defs.bzl", "pcl_library")
load("@pcl_deps//:defs.bzl", "pcl_dep")

pcl_library(
    name = "pcl_hub_dep",
    srcs = [
        "rio.pcl",
    ],
    deps = [
        # This allows access to any dependency listed in `pcl_hub_deps`
        "@pcl_deps//:all_deps",
    ],
)
```

You can see an example of this in action [within the Federation's
own test suite](../../../tests/general/pcl/pcl_hub_dep/BUILD.bazel)

### Using file generation rules

This is the equivalent of running the `pcl` CLI on the command line.

In your `BUILD.bazel` file:

```starlark
load("@apple_federation//pcl:defs.bzl", "pcl_test")

pcl_test(
    name = "my-config",
    srcs = [":config.pcl"],
)
```

See the `example/` directory for a complete example.

#### Using the Java API

- Define your configuration in a Pcl file:

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
      srcs = glob(["where/your/schema/is/*.pcl"]),
      visibility = [
          "//visibility:public",
      ]
  )
  ```

- (Optional) Define Java POJOs from your configuration schema in a `BUILD` file:

  ```starlark
  load("@apple_federation//pcl:defs.bzl", "pcl_config_java_library")

  pcl_config_java_library(
      name = "java_library_name",
      files=[
          "//path/to/your:config_schema
      ]
  )
  ```
