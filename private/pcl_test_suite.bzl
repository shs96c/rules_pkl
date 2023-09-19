load(":pcl.bzl", "pcl_test")
load(":pcl_library.bzl", "pcl_library")

def pcl_test_suite(
        name,
        srcs,
        deps = None,
        tags = [],
        visibility = None,
        size = None,
        test_suffix = None,
        executor = None,
        **kwargs):
    """Create a suite of pcl tests from the provided files files.

    Given the list of `srcs`, this macro will generate:

    1. A `pcl_test` target (with visibility:private) per `src` that ends with `test_suffix`
    2. A `pcl_library` that accumulates any files that don't match `test_suffix`
    3. A `native.test_suite` that accumulates all of the `pcl_test` targets
    """
    if test_suffix == None:
        test_suffix = "_test.pcl"

    if deps == None:
        deps = []

    test_srcs = [test for test in srcs if test.endswith(test_suffix)]
    nontest_srcs = [test for test in srcs if not test.endswith(test_suffix)]

    if nontest_srcs:
        lib_dep_name = "%s-test-lib" % name
        lib_dep_label = ":%s" % lib_dep_name

        pcl_library(
            name = lib_dep_name,
            srcs = nontest_srcs,
            deps = deps,
            visibility = visibility,
        )

        if lib_dep_label not in deps:
            deps.append(lib_dep_label)

    tests = []

    for src in test_srcs:
        test_name = src.replace(".pcl", "")

        pcl_test(
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
