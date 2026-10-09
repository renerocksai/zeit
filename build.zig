const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("zeit", .{
        .root_source_file = b.path("src/zeit.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib_unit_tests = b.addTest(.{ .root_module = mod });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);

    const docs_object = b.addObject(.{ .name = "zeit-docs", .root_module = mod });
    const install_docs = b.addInstallDirectory(.{
        .source_dir = docs_object.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    });
    const docs_step = b.step("docs", "Generate API documentation");
    docs_step.dependOn(&install_docs.step);

    const fmt = b.addFmt(.{
        .paths = b.pathList(&.{ "build.zig", "build.zig.zon", "src" }),
        .check = true,
    });
    const verify = b.step("verify", "Check formatting, run tests and generate documentation");
    verify.dependOn(&fmt.step);
    verify.dependOn(test_step);
    verify.dependOn(docs_step);
}
