<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Public API re-exports

<a id="pkl_codegen_java_toolchain"></a>

## pkl_codegen_java_toolchain

<pre>
pkl_codegen_java_toolchain(<a href="#pkl_codegen_java_toolchain-name">name</a>, <a href="#pkl_codegen_java_toolchain-cli">cli</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="pkl_codegen_java_toolchain-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="pkl_codegen_java_toolchain-cli"></a>cli |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `//pkl:pkl_codegen_cli`  |


<a id="pkl_doc_toolchain"></a>

## pkl_doc_toolchain

<pre>
pkl_doc_toolchain(<a href="#pkl_doc_toolchain-name">name</a>, <a href="#pkl_doc_toolchain-cli">cli</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="pkl_doc_toolchain-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="pkl_doc_toolchain-cli"></a>cli |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `//pkl:pkl_doc_cli`  |


<a id="pkl_library"></a>

## pkl_library

<pre>
pkl_library(<a href="#pkl_library-name">name</a>, <a href="#pkl_library-deps">deps</a>, <a href="#pkl_library-srcs">srcs</a>, <a href="#pkl_library-data">data</a>)
</pre>

Collect Pkl sources together so they can be used by other `rules_pkl` rules.

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
pkl_run(<a href="#pkl_run-name">name</a>, <a href="#pkl_run-deps">deps</a>, <a href="#pkl_run-srcs">srcs</a>, <a href="#pkl_run-data">data</a>, <a href="#pkl_run-out">out</a>, <a href="#pkl_run-entrypoints">entrypoints</a>, <a href="#pkl_run-expression">expression</a>, <a href="#pkl_run-format">format</a>, <a href="#pkl_run-multiple_outputs">multiple_outputs</a>, <a href="#pkl_run-properties">properties</a>)
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
| <a id="pkl_run-expression"></a>expression |  A pkl expression to evaluate within the module. Note that the `format` attribute does not affect how this renders.   | String | optional |  `""`  |
| <a id="pkl_run-format"></a>format |  The format of the generated file to pass when calling `pkl`. See https://pages.github.pie.apple.com/pkl/main/current/pkl-cli/index.html#options.   | String | optional |  `""`  |
| <a id="pkl_run-multiple_outputs"></a>multiple_outputs |  Whether to expect to render multiple file outputs to a single directory with the name of the target (see https://pkl.apple.com/main/current/language-reference/index.html#multiple-file-output). This flag is mutually exclusive with the `out` attribute.   | Boolean | optional |  `False`  |
| <a id="pkl_run-properties"></a>properties |  Dictionary of name value pairs used to pass in PKL external properties See the Pkl docs: https://pages.github.pie.apple.com/pkl/main/current/language-reference/index.html#resources   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |


<a id="pkl_test"></a>

## pkl_test

<pre>
pkl_test(<a href="#pkl_test-name">name</a>, <a href="#pkl_test-deps">deps</a>, <a href="#pkl_test-srcs">srcs</a>, <a href="#pkl_test-data">data</a>, <a href="#pkl_test-out">out</a>, <a href="#pkl_test-entrypoints">entrypoints</a>, <a href="#pkl_test-expression">expression</a>, <a href="#pkl_test-format">format</a>, <a href="#pkl_test-multiple_outputs">multiple_outputs</a>, <a href="#pkl_test-properties">properties</a>)
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
| <a id="pkl_test-expression"></a>expression |  A pkl expression to evaluate within the module. Note that the `format` attribute does not affect how this renders.   | String | optional |  `""`  |
| <a id="pkl_test-format"></a>format |  The format of the generated file to pass when calling `pkl`. See https://pages.github.pie.apple.com/pkl/main/current/pkl-cli/index.html#options.   | String | optional |  `""`  |
| <a id="pkl_test-multiple_outputs"></a>multiple_outputs |  Whether to expect to render multiple file outputs to a single directory with the name of the target (see https://pkl.apple.com/main/current/language-reference/index.html#multiple-file-output). This flag is mutually exclusive with the `out` attribute.   | Boolean | optional |  `False`  |
| <a id="pkl_test-properties"></a>properties |  Dictionary of name value pairs used to pass in PKL external properties See the Pkl docs: https://pages.github.pie.apple.com/pkl/main/current/language-reference/index.html#resources   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |


<a id="pkl_toolchain"></a>

## pkl_toolchain

<pre>
pkl_toolchain(<a href="#pkl_toolchain-name">name</a>, <a href="#pkl_toolchain-cli">cli</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="pkl_toolchain-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="pkl_toolchain-cli"></a>cli |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `//pkl:pkl_cli`  |


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


<a id="pkl_test_suite"></a>

## pkl_test_suite

<pre>
pkl_test_suite(<a href="#pkl_test_suite-name">name</a>, <a href="#pkl_test_suite-srcs">srcs</a>, <a href="#pkl_test_suite-deps">deps</a>, <a href="#pkl_test_suite-tags">tags</a>, <a href="#pkl_test_suite-visibility">visibility</a>, <a href="#pkl_test_suite-size">size</a>, <a href="#pkl_test_suite-test_suffix">test_suffix</a>, <a href="#pkl_test_suite-executor">executor</a>, <a href="#pkl_test_suite-kwargs">kwargs</a>)
</pre>

Create a suite of pkl tests from the provided files.

Given the list of `srcs`, this macro will generate:

1. A `pkl_test` target (with visibility:private) per `src` that ends with `test_suffix`
2. A `pkl_library` that accumulates any files that don't match `test_suffix`
3. A `native.test_suite` that accumulates all of the `pkl_test` targets

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="pkl_test_suite-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="pkl_test_suite-srcs"></a>srcs |  <p align="center"> - </p>   |  none |
| <a id="pkl_test_suite-deps"></a>deps |  <p align="center"> - </p>   |  `None` |
| <a id="pkl_test_suite-tags"></a>tags |  <p align="center"> - </p>   |  `[]` |
| <a id="pkl_test_suite-visibility"></a>visibility |  <p align="center"> - </p>   |  `None` |
| <a id="pkl_test_suite-size"></a>size |  <p align="center"> - </p>   |  `None` |
| <a id="pkl_test_suite-test_suffix"></a>test_suffix |  <p align="center"> - </p>   |  `None` |
| <a id="pkl_test_suite-executor"></a>executor |  <p align="center"> - </p>   |  `None` |
| <a id="pkl_test_suite-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


