load("@pkl_constants//:constants.bzl", _PKL_DEPS = "PKL_DEPS", _PKL_VERSION = "PKL_VERSION")
load("//pkl/private:pkl_hub_deps.bzl", _pkl_hub_deps = "pkl_hub_deps")

PKL_DEPS = _PKL_DEPS
PKL_VERSION = _PKL_VERSION

pkl_hub_deps = _pkl_hub_deps
