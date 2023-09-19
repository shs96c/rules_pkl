load(":pkl.bzl", "pkl_test")
load(":pkl_library.bzl", "pkl_library")

def pkl_test_suite(
        name,
        srcs,
        deps = None,
        tags = [],
        visibility = None,
        size = None,
        test_suffix = None,
        executor = None,
        **kwargs):
    """Create a suite of pkl tests from the provided files files.

    Given the list of `srcs`, this macro will generate:

    1. A `pkl_test` target (with visibility:private) per `src` that ends with `test_suffix`
    2. A `pkl_library` that accumulates any files that don't match `test_suffix`
    3. A `native.test_suite` that accumulates all of the `pkl_test` targets
    """
    if test_suffix == None:
        test_suffix = "_test.pkl"

    if deps == None:
        deps = []

    test_srcs = [test for test in srcs if test.endswith(test_suffix)]
    nontest_srcs = [test for test in srcs if not test.endswith(test_suffix)]

    if nontest_srcs:
        lib_dep_name = "%s-test-lib" % name
        lib_dep_label = ":%s" % lib_dep_name

        pkl_library(
            name = lib_dep_name,
            srcs = nontest_srcs,
            deps = deps,
            visibility = visibility,
        )

        if lib_dep_label not in deps:
            deps.append(lib_dep_label)

    tests = []

    for src in test_srcs:
        test_name = src.replace(".pkl", "")

        pkl_test(
            name = test_name,
            srcs = [src],
            size = size,
            deps = deps,
            tags = tags,
            executor = executor,
            visibility = ["//visibility:private"],
            **kwargs
        )

        tests.append(test_name)

    native.test_suite(
        name = name,
        tests = tests,
        tags = tags,
        visibility = visibility,
    )
