const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zigonic_mod = b.addModule("zigonic", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .name = "zigonic",
        .linkage = .static,
        .root_module = zigonic_mod,
    });
    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "zigonic-example",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "zigonic", .module = zigonic_mod },
            },
        }),
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the example application");
    run_step.dependOn(&run_cmd.step);

    // Tests
    const test_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const lib_unit_tests = b.addTest(.{
        .root_module = test_mod,
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);

    // Documentation
    const docs_mod = b.addModule("zigonic-docs", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = .Debug,
    });
    const docs_lib = b.addLibrary(.{
        .name = "zigonic-docs",
        .linkage = .static,
        .root_module = docs_mod,
    });
    const install_docs = b.addInstallDirectory(.{
        .source_dir = docs_lib.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    });
    const docs_step = b.step("docs", "Generate documentation");
    docs_step.dependOn(&install_docs.step);

    // Check step
    const check_mod = b.addModule("zigonic-check", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const check_lib = b.addLibrary(.{
        .name = "zigonic-check",
        .linkage = .static,
        .root_module = check_mod,
    });
    const check_step = b.step("check", "Check if the code compiles");
    check_step.dependOn(&check_lib.step);
}
