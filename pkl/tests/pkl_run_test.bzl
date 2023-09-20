"""Unit tests for pkl_run rule
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//pkl/private:pkl.bzl", "pkl_run")

def _smoke_test_impl(ctx):
    env = unittest.begin(ctx)
    asserts.equals(env, "got to pkl_run implementation", pkl_run)
    return unittest.end(env)

# The unittest library requires that we export the test cases as named test rules,
# but their names are arbitrary and don't appear anywhere.
_t0_test = unittest.make(_smoke_test_impl)

def pkl_run_test_suite(name):
    unittest.suite(name, _t0_test)
