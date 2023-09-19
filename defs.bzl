load(
    "//pcl/private:pcl.bzl",
    _PCL_JVM_FLAGS = "PCL_JVM_FLAGS",
    _pcl_run = "pcl_run",
    _pcl_test = "pcl_test",
)
load(
    "//pcl/private:pcl_codegen.bzl",
    _pcl_config_java_library = "pcl_config_java_library",
    _pcl_config_src = "pcl_config_src",
)
load("//pcl/private:pcl_doc.bzl", _pcl_doc = "pcl_doc")
load("//pcl/private:pcl_library.bzl", _pcl_library = "pcl_library")
load("//pcl/private:pcl_test_suite.bzl", _pcl_test_suite = "pcl_test_suite")

PCL_JVM_FLAGS = _PCL_JVM_FLAGS

pcl_config_java_library = _pcl_config_java_library
pcl_config_src = _pcl_config_src
pcl_doc = _pcl_doc
pcl_library = _pcl_library
pcl_run = _pcl_run
pcl_test = _pcl_test
pcl_test_suite = _pcl_test_suite
