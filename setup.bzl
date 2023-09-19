load("//common:setup.bzl", "common_setup")
load("@apple_federation_java_deps//:defs.bzl", _pinned_federation_maven_install = "pinned_maven_install")

def pcl_setup():
    common_setup()
    _pinned_federation_maven_install()
