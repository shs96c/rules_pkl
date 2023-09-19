load("@pcl_constants//:constants.bzl", _PCL_DEPS = "PCL_DEPS", _PCL_VERSION = "PCL_VERSION")
load("//pcl/private:pcl_hub_deps.bzl", _pcl_hub_deps = "pcl_hub_deps")

PCL_DEPS = _PCL_DEPS
PCL_VERSION = _PCL_VERSION

pcl_hub_deps = _pcl_hub_deps
