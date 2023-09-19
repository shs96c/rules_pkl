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

<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="pcl_hub_deps"></a>

## pcl_hub_deps

<pre>
pcl_hub_deps(<a href="#pcl_hub_deps-name">name</a>, <a href="#pcl_hub_deps-deps">deps</a>, <a href="#pcl_hub_deps-lock_file">lock_file</a>, <a href="#pcl_hub_deps-repo_mapping">repo_mapping</a>, <a href="#pcl_hub_deps-repositories">repositories</a>)
</pre>

Used for caching items from Pcl Hub so they don't need to be downloaded by the Pcl binary.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="pcl_hub_deps-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="pcl_hub_deps-deps"></a>deps |  A list of Pcl "module URI"s.   | List of strings | optional |  `[]`  |
| <a id="pcl_hub_deps-lock_file"></a>lock_file |  The lock file to use.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="pcl_hub_deps-repo_mapping"></a>repo_mapping |  A dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.<p>For example, an entry `"@foo": "@bar"` declares that, for any time this repository depends on `@foo` (such as a dependency on `@foo//some:target`, it should actually resolve that dependency within globally-declared `@bar` (`@bar//some:target`).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | required |  |
| <a id="pcl_hub_deps-repositories"></a>repositories |  A dict mapping Pcl Hub name (eg. `applehub`) to a base URL.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{"applehub": "https://artifacts.apple.com/pcl/"}`  |


<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="pcl_library"></a>

## pcl_library

<pre>
pcl_library(<a href="#pcl_library-name">name</a>, <a href="#pcl_library-deps">deps</a>, <a href="#pcl_library-srcs">srcs</a>, <a href="#pcl_library-data">data</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="pcl_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="pcl_library-deps"></a>deps |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pcl_library-srcs"></a>srcs |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="pcl_library-data"></a>data |  Files to make available in the filesystem when building this configuration. These can be accessed by relative path.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |


<a id="pcl_run"></a>

## pcl_run

<pre>
pcl_run(<a href="#pcl_run-name">name</a>, <a href="#pcl_run-deps">deps</a>, <a href="#pcl_run-srcs">srcs</a>, <a href="#pcl_run-data">data</a>, <a href="#pcl_run-out">out</a>, <a href="#pcl_run-entrypoints">entrypoints</a>, <a href="#pcl_run-executor">executor</a>, <a href="#pcl_run-expression">expression</a>, <a href="#pcl_run-format">format</a>, <a href="#pcl_run-jvm_flags">jvm_flags</a>,
        <a href="#pcl_run-multiple_outputs">multiple_outputs</a>, <a href="#pcl_run-properties">properties</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="pcl_run-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="pcl_run-deps"></a>deps |  Other targets to include in the pcl module path when building this configuration. Must be `pcl_*` targets.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pcl_run-srcs"></a>srcs |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pcl_run-data"></a>data |  Files to make available in the filesystem when building this configuration. These can be accessed by relative path.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pcl_run-out"></a>out |  Name of the output file to generate. Defaults to `<rule name>.<format>`. If the format attribute is unset, use `<rule name>.pcf`. This flag is mutually exclusive with the `multiple_outputs` attribute.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  |
| <a id="pcl_run-entrypoints"></a>entrypoints |  The pcl file to use as an entry point (needs to be part of the srcs). Typically a single file.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pcl_run-executor"></a>executor |  Pcl executor to be used. One of: `java`, `native` (default)   | String | optional |  `"native"`  |
| <a id="pcl_run-expression"></a>expression |  A pcl expression to evaluate within the module. Note that the `format` attribute does not affect how this renders.   | String | optional |  `""`  |
| <a id="pcl_run-format"></a>format |  The format of the generated file to pass when calling `pcl`. See https://pages.github.pie.apple.com/pcl/main/current/pcl-cli/index.html#options.   | String | optional |  `""`  |
| <a id="pcl_run-jvm_flags"></a>jvm_flags |  Optional list of flags to pass to the java process running Pcl. Only used if `executor` is `java`   | List of strings | optional |  `[]`  |
| <a id="pcl_run-multiple_outputs"></a>multiple_outputs |  Whether to expect to render multiple file outputs to a single directory with the name of the target (see https://pcl.apple.com/main/current/language-reference/index.html#multiple-file-output). This flag is mutually exclusive with the `out` attribute.   | Boolean | optional |  `False`  |
| <a id="pcl_run-properties"></a>properties |  Dictionary of name value pairs used to pass in PCL external properties See the Pcl docs: https://pages.github.pie.apple.com/pcl/main/current/language-reference/index.html#resources   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |


<a id="pcl_test"></a>

## pcl_test

<pre>
pcl_test(<a href="#pcl_test-name">name</a>, <a href="#pcl_test-deps">deps</a>, <a href="#pcl_test-srcs">srcs</a>, <a href="#pcl_test-data">data</a>, <a href="#pcl_test-out">out</a>, <a href="#pcl_test-entrypoints">entrypoints</a>, <a href="#pcl_test-executor">executor</a>, <a href="#pcl_test-expression">expression</a>, <a href="#pcl_test-format">format</a>, <a href="#pcl_test-jvm_flags">jvm_flags</a>,
         <a href="#pcl_test-multiple_outputs">multiple_outputs</a>, <a href="#pcl_test-properties">properties</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="pcl_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="pcl_test-deps"></a>deps |  Other targets to include in the pcl module path when building this configuration. Must be `pcl_*` targets.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pcl_test-srcs"></a>srcs |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pcl_test-data"></a>data |  Files to make available in the filesystem when building this configuration. These can be accessed by relative path.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pcl_test-out"></a>out |  Name of the output file to generate. Defaults to `<rule name>.<format>`. If the format attribute is unset, use `<rule name>.pcf`. This flag is mutually exclusive with the `multiple_outputs` attribute.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  |
| <a id="pcl_test-entrypoints"></a>entrypoints |  The pcl file to use as an entry point (needs to be part of the srcs). Typically a single file.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pcl_test-executor"></a>executor |  Pcl executor to be used. One of: `java`, `native` (default)   | String | optional |  `"native"`  |
| <a id="pcl_test-expression"></a>expression |  A pcl expression to evaluate within the module. Note that the `format` attribute does not affect how this renders.   | String | optional |  `""`  |
| <a id="pcl_test-format"></a>format |  The format of the generated file to pass when calling `pcl`. See https://pages.github.pie.apple.com/pcl/main/current/pcl-cli/index.html#options.   | String | optional |  `""`  |
| <a id="pcl_test-jvm_flags"></a>jvm_flags |  Optional list of flags to pass to the java process running Pcl. Only used if `executor` is `java`   | List of strings | optional |  `[]`  |
| <a id="pcl_test-multiple_outputs"></a>multiple_outputs |  Whether to expect to render multiple file outputs to a single directory with the name of the target (see https://pcl.apple.com/main/current/language-reference/index.html#multiple-file-output). This flag is mutually exclusive with the `out` attribute.   | Boolean | optional |  `False`  |
| <a id="pcl_test-properties"></a>properties |  Dictionary of name value pairs used to pass in PCL external properties See the Pcl docs: https://pages.github.pie.apple.com/pcl/main/current/language-reference/index.html#resources   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |


<a id="pcl_config_java_library"></a>

## pcl_config_java_library

<pre>
pcl_config_java_library(<a href="#pcl_config_java_library-name">name</a>, <a href="#pcl_config_java_library-files">files</a>, <a href="#pcl_config_java_library-module_path">module_path</a>, <a href="#pcl_config_java_library-generate_getters">generate_getters</a>, <a href="#pcl_config_java_library-deps">deps</a>, <a href="#pcl_config_java_library-tags">tags</a>, <a href="#pcl_config_java_library-kwargs">kwargs</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="pcl_config_java_library-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="pcl_config_java_library-files"></a>files |  <p align="center"> - </p>   |  none |
| <a id="pcl_config_java_library-module_path"></a>module_path |  <p align="center"> - </p>   |  `[]` |
| <a id="pcl_config_java_library-generate_getters"></a>generate_getters |  <p align="center"> - </p>   |  `None` |
| <a id="pcl_config_java_library-deps"></a>deps |  <p align="center"> - </p>   |  `[]` |
| <a id="pcl_config_java_library-tags"></a>tags |  <p align="center"> - </p>   |  `[]` |
| <a id="pcl_config_java_library-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


<a id="pcl_config_src"></a>

## pcl_config_src

<pre>
pcl_config_src(<a href="#pcl_config_src-name">name</a>, <a href="#pcl_config_src-files">files</a>, <a href="#pcl_config_src-module_path">module_path</a>, <a href="#pcl_config_src-kwargs">kwargs</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="pcl_config_src-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="pcl_config_src-files"></a>files |  <p align="center"> - </p>   |  none |
| <a id="pcl_config_src-module_path"></a>module_path |  <p align="center"> - </p>   |  `None` |
| <a id="pcl_config_src-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


<a id="pcl_doc"></a>

## pcl_doc

<pre>
pcl_doc(<a href="#pcl_doc-name">name</a>, <a href="#pcl_doc-srcs">srcs</a>, <a href="#pcl_doc-kwargs">kwargs</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="pcl_doc-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="pcl_doc-srcs"></a>srcs |  <p align="center"> - </p>   |  none |
| <a id="pcl_doc-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


