load("@rules_jvm_external//:defs.bzl", "artifact")

def _to_short_path(f, expander):
    return f.tree_relative_path + "=" + f.path

def _zipit(ctx, outfile, files):
    zip_args = ctx.actions.args()
    zip_args.add_all("cC", [outfile.path])
    zip_args.add_all(files, map_each = _to_short_path)
    ctx.actions.run(
        inputs = files,
        outputs = [outfile],
        executable = ctx.executable._zip,
        arguments = [zip_args],
        progress_message = "Writing via zip: %s" % outfile.basename,
    )

def _pkl_codegen_impl(ctx):
    modules = depset(transitive = [depset(dep[JavaInfo].runtime_output_jars) for dep in ctx.attr.module_path]).to_list()
    java_codegen_toolchain = ctx.toolchains["//pkl:codegen_toolchain_type"]
    codegen_cli = java_codegen_toolchain.codegen_cli

    # Generate Java from PKL
    outdir = ctx.actions.declare_directory(ctx.attr.name, sibling = None)
    gen_args = ctx.actions.args()

    gen_args.add("--no-cache")
    if len(modules):
        gen_args.add_all(["--module-path", ctx.configuration.host_path_separator.join([module.path for module in modules])])
    if ctx.attr.generate_getters:
        gen_args.add_all(["--generate-getters"])
    gen_args.add_all("-o", [outdir.path])
    gen_args.add_all(ctx.files.files)

    ctx.actions.run(
        inputs = ctx.files.files + modules,
        outputs = [outdir],
        executable = java_codegen_toolchain.codegen_cli,
        arguments = [gen_args],
        tools = [
            java_codegen_toolchain.cli_files_to_run,
        ],
        progress_message = "Generating Java sources from Pkl %s" % (ctx.label),
    )

    # Create JAR
    outjar = ctx.outputs.out
    _zipit(
        ctx = ctx,
        outfile = ctx.outputs.out,
        files = [outdir],
    )

    # Return JAR
    return OutputGroupInfo(out = [outjar])

_pkl_codegen = rule(
    _pkl_codegen_impl,
    attrs = {
        "files": attr.label_list(
            mandatory = True,
            allow_files = [".pkl"],
        ),
        "generate_getters": attr.bool(
            doc = "Whether to generate getters in the AppConfig. Defaults to True",
            default = True,
        ),
        "module_path": attr.label_list(
            providers = [
                [JavaInfo],
            ],
        ),
        "out": attr.output(),
        "_zip": attr.label(
            allow_single_file = True,
            cfg = "exec",
            default = "@bazel_tools//tools/zip:zipper",
            executable = True,
        ),
    },
    toolchains = [
        "//pkl:codegen_toolchain_type",
    ],
)

def pkl_config_src(name, files, module_path = None, **kwargs):
    _pkl_codegen(
        name = name,
        files = files,
        module_path = module_path,
        out = name + "_codegen.srcjar",
        **kwargs
    )

def pkl_config_java_library(name, files, module_path = [], generate_getters = None, deps = [], tags = [], **kwargs):
    name_generated_code = name + "_pkl"

    pkl_config_src(
        name = name_generated_code,
        files = files,
        generate_getters = generate_getters,
        module_path = module_path,
        tags = tags,
    )

    pkl_deps = [artifact("com.apple.pkl:pkl-config-java", repository_name = "rules_pkl_deps")]

    # Ensure that there are no duplicate entries in the deps
    all_deps = depset(
        pkl_deps + module_path,
        transitive = [depset([dep]) for dep in deps],
    )

    native.java_library(
        name = name,
        srcs = [name_generated_code],
        deps = all_deps.to_list(),
        resources = files,
        tags = tags + [] if "no-lint" in tags else ["no-lint"],
        **kwargs
    )
