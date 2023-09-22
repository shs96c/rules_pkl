# Pkl Rules

[Pkl](www.pkl-lang.org) is an embeddable configuration language with rich support for data templating and
validation. It can be used from the command line, integrated in a build pipeline, or embedded in a
program. Pkl scales from small to large, simple to complex, ad-hoc to repetitive configuration
tasks.

It can be used to specify and verify configuration, and to provide a well-defined
schema for configuration that can be shared across components. It can also be used to generate
configuration POJOs.

For further information about Pkl, check out the (official PKL documentation)[www.pkl-lang.org/main/current].

## Quick Start

### Setup

To use `rules_pkl` enable `bzlmod` within your project, and then add the following to your `MODULE.bazel`:

```starlark
# Please check the releases page on GitHub for the latest released version
bazel_dep(name = "rules_pkl", version = "1.0.0")
```

## Examples

See the `example/` directory for complete examples of how to use `rules_pkl`.

