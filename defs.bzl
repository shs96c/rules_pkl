load(
    "//pkl/private:pkl.bzl",
    _PKL_JVM_FLAGS = "PKL_JVM_FLAGS",
    _pkl_run = "pkl_run",
    _pkl_test = "pkl_test",
)
load(
    "//pkl/private:pkl_codegen.bzl",
    _pkl_config_java_library = "pkl_config_java_library",
    _pkl_config_src = "pkl_config_src",
)
load("//pkl/private:pkl_doc.bzl", _pkl_doc = "pkl_doc")
load("//pkl/private:pkl_library.bzl", _pkl_library = "pkl_library")
load("//pkl/private:pkl_test_suite.bzl", _pkl_test_suite = "pkl_test_suite")

PKL_JVM_FLAGS = _PKL_JVM_FLAGS

pkl_config_java_library = _pkl_config_java_library
pkl_config_src = _pkl_config_src
pkl_doc = _pkl_doc
pkl_library = _pkl_library
pkl_run = _pkl_run
pkl_test = _pkl_test
pkl_test_suite = _pkl_test_suite
