# Pkl Rules

[Pkl](www.pkl-lang.org) is an embeddable configuration language with rich support for data templating and
validation. It can be used from the command line, integrated in a build pipeline, or embedded in a
program. Pkl scales from small to large, simple to complex, ad-hoc to repetitive configuration
tasks.

It can be used within Valentine to specify, verify configuration and to provide a well-defined
schema for configuration that can be shared across components. It can also be used to generate
configuration POJOs.

For further information about Pkl, check out the (official PKL documentation)[www.pkl-lang.org/main/current].

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

<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="pkl_hub_deps"></a>

## pkl_hub_deps

<pre>
pkl_hub_deps(<a href="#pkl_hub_deps-name">name</a>, <a href="#pkl_hub_deps-deps">deps</a>, <a href="#pkl_hub_deps-lock_file">lock_file</a>, <a href="#pkl_hub_deps-repo_mapping">repo_mapping</a>, <a href="#pkl_hub_deps-repositories">repositories</a>)
</pre>

Used for caching items from Pkl Hub so they don't need to be downloaded by the Pkl binary.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="pkl_hub_deps-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="pkl_hub_deps-deps"></a>deps |  A list of Pkl "module URI"s.   | List of strings | optional |  `[]`  |
| <a id="pkl_hub_deps-lock_file"></a>lock_file |  The lock file to use.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="pkl_hub_deps-repo_mapping"></a>repo_mapping |  A dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.<p>For example, an entry `"@foo": "@bar"` declares that, for any time this repository depends on `@foo` (such as a dependency on `@foo//some:target`, it should actually resolve that dependency within globally-declared `@bar` (`@bar//some:target`).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | required |  |
| <a id="pkl_hub_deps-repositories"></a>repositories |  A dict mapping Pkl Hub name (eg. `applehub`) to a base URL.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{"applehub": "https://artifacts.apple.com/pkl/"}`  |


<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="pkl_library"></a>

## pkl_library

<pre>
pkl_library(<a href="#pkl_library-name">name</a>, <a href="#pkl_library-deps">deps</a>, <a href="#pkl_library-srcs">srcs</a>, <a href="#pkl_library-data">data</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="pkl_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="pkl_library-deps"></a>deps |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pkl_library-srcs"></a>srcs |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="pkl_library-data"></a>data |  Files to make available in the filesystem when building this configuration. These can be accessed by relative path.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |


<a id="pkl_run"></a>

## pkl_run

<pre>
pkl_run(<a href="#pkl_run-name">name</a>, <a href="#pkl_run-deps">deps</a>, <a href="#pkl_run-srcs">srcs</a>, <a href="#pkl_run-data">data</a>, <a href="#pkl_run-out">out</a>, <a href="#pkl_run-entrypoints">entrypoints</a>, <a href="#pkl_run-executor">executor</a>, <a href="#pkl_run-expression">expression</a>, <a href="#pkl_run-format">format</a>, <a href="#pkl_run-jvm_flags">jvm_flags</a>,
        <a href="#pkl_run-multiple_outputs">multiple_outputs</a>, <a href="#pkl_run-properties">properties</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="pkl_run-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="pkl_run-deps"></a>deps |  Other targets to include in the pkl module path when building this configuration. Must be `pkl_*` targets.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pkl_run-srcs"></a>srcs |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pkl_run-data"></a>data |  Files to make available in the filesystem when building this configuration. These can be accessed by relative path.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pkl_run-out"></a>out |  Name of the output file to generate. Defaults to `<rule name>.<format>`. If the format attribute is unset, use `<rule name>.pcf`. This flag is mutually exclusive with the `multiple_outputs` attribute.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  |
| <a id="pkl_run-entrypoints"></a>entrypoints |  The pkl file to use as an entry point (needs to be part of the srcs). Typically a single file.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pkl_run-executor"></a>executor |  Pkl executor to be used. One of: `java`, `native` (default)   | String | optional |  `"native"`  |
| <a id="pkl_run-expression"></a>expression |  A pkl expression to evaluate within the module. Note that the `format` attribute does not affect how this renders.   | String | optional |  `""`  |
| <a id="pkl_run-format"></a>format |  The format of the generated file to pass when calling `pkl`. See https://pages.github.pie.apple.com/pkl/main/current/pkl-cli/index.html#options.   | String | optional |  `""`  |
| <a id="pkl_run-jvm_flags"></a>jvm_flags |  Optional list of flags to pass to the java process running Pkl. Only used if `executor` is `java`   | List of strings | optional |  `[]`  |
| <a id="pkl_run-multiple_outputs"></a>multiple_outputs |  Whether to expect to render multiple file outputs to a single directory with the name of the target (see https://pkl.apple.com/main/current/language-reference/index.html#multiple-file-output). This flag is mutually exclusive with the `out` attribute.   | Boolean | optional |  `False`  |
| <a id="pkl_run-properties"></a>properties |  Dictionary of name value pairs used to pass in PKL external properties See the Pkl docs: https://pages.github.pie.apple.com/pkl/main/current/language-reference/index.html#resources   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |


<a id="pkl_test"></a>

## pkl_test

<pre>
pkl_test(<a href="#pkl_test-name">name</a>, <a href="#pkl_test-deps">deps</a>, <a href="#pkl_test-srcs">srcs</a>, <a href="#pkl_test-data">data</a>, <a href="#pkl_test-out">out</a>, <a href="#pkl_test-entrypoints">entrypoints</a>, <a href="#pkl_test-executor">executor</a>, <a href="#pkl_test-expression">expression</a>, <a href="#pkl_test-format">format</a>, <a href="#pkl_test-jvm_flags">jvm_flags</a>,
         <a href="#pkl_test-multiple_outputs">multiple_outputs</a>, <a href="#pkl_test-properties">properties</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="pkl_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="pkl_test-deps"></a>deps |  Other targets to include in the pkl module path when building this configuration. Must be `pkl_*` targets.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pkl_test-srcs"></a>srcs |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pkl_test-data"></a>data |  Files to make available in the filesystem when building this configuration. These can be accessed by relative path.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pkl_test-out"></a>out |  Name of the output file to generate. Defaults to `<rule name>.<format>`. If the format attribute is unset, use `<rule name>.pcf`. This flag is mutually exclusive with the `multiple_outputs` attribute.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  |
| <a id="pkl_test-entrypoints"></a>entrypoints |  The pkl file to use as an entry point (needs to be part of the srcs). Typically a single file.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pkl_test-executor"></a>executor |  Pkl executor to be used. One of: `java`, `native` (default)   | String | optional |  `"native"`  |
| <a id="pkl_test-expression"></a>expression |  A pkl expression to evaluate within the module. Note that the `format` attribute does not affect how this renders.   | String | optional |  `""`  |
| <a id="pkl_test-format"></a>format |  The format of the generated file to pass when calling `pkl`. See https://pages.github.pie.apple.com/pkl/main/current/pkl-cli/index.html#options.   | String | optional |  `""`  |
| <a id="pkl_test-jvm_flags"></a>jvm_flags |  Optional list of flags to pass to the java process running Pkl. Only used if `executor` is `java`   | List of strings | optional |  `[]`  |
| <a id="pkl_test-multiple_outputs"></a>multiple_outputs |  Whether to expect to render multiple file outputs to a single directory with the name of the target (see https://pkl.apple.com/main/current/language-reference/index.html#multiple-file-output). This flag is mutually exclusive with the `out` attribute.   | Boolean | optional |  `False`  |
| <a id="pkl_test-properties"></a>properties |  Dictionary of name value pairs used to pass in PKL external properties See the Pkl docs: https://pages.github.pie.apple.com/pkl/main/current/language-reference/index.html#resources   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |


<a id="pkl_config_java_library"></a>

## pkl_config_java_library

<pre>
pkl_config_java_library(<a href="#pkl_config_java_library-name">name</a>, <a href="#pkl_config_java_library-files">files</a>, <a href="#pkl_config_java_library-module_path">module_path</a>, <a href="#pkl_config_java_library-generate_getters">generate_getters</a>, <a href="#pkl_config_java_library-deps">deps</a>, <a href="#pkl_config_java_library-tags">tags</a>, <a href="#pkl_config_java_library-kwargs">kwargs</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="pkl_config_java_library-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="pkl_config_java_library-files"></a>files |  <p align="center"> - </p>   |  none |
| <a id="pkl_config_java_library-module_path"></a>module_path |  <p align="center"> - </p>   |  `[]` |
| <a id="pkl_config_java_library-generate_getters"></a>generate_getters |  <p align="center"> - </p>   |  `None` |
| <a id="pkl_config_java_library-deps"></a>deps |  <p align="center"> - </p>   |  `[]` |
| <a id="pkl_config_java_library-tags"></a>tags |  <p align="center"> - </p>   |  `[]` |
| <a id="pkl_config_java_library-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


<a id="pkl_config_src"></a>

## pkl_config_src

<pre>
pkl_config_src(<a href="#pkl_config_src-name">name</a>, <a href="#pkl_config_src-files">files</a>, <a href="#pkl_config_src-module_path">module_path</a>, <a href="#pkl_config_src-kwargs">kwargs</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="pkl_config_src-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="pkl_config_src-files"></a>files |  <p align="center"> - </p>   |  none |
| <a id="pkl_config_src-module_path"></a>module_path |  <p align="center"> - </p>   |  `None` |
| <a id="pkl_config_src-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


<a id="pkl_doc"></a>

## pkl_doc

<pre>
pkl_doc(<a href="#pkl_doc-name">name</a>, <a href="#pkl_doc-srcs">srcs</a>, <a href="#pkl_doc-kwargs">kwargs</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="pkl_doc-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="pkl_doc-srcs"></a>srcs |  <p align="center"> - </p>   |  none |
| <a id="pkl_doc-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


