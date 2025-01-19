const std = @import("std");

const TestFile = struct {
    path: []const u8,
};

pub fn build(b: *std.Build) void {
    const exe = createExecutable(b, "zigonic", "src/main.zig");
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    setupRunStep(b, run_cmd);

    const tests = [_]TestFile{
        .{ .path = "src/tests/all_of_test.zig" },
        .{ .path = "src/tests/max_element_test.zig" },
        .{ .path = "src/tests/any_of_test.zig" },
        .{ .path = "src/tests/binary_search_test.zig" },
        .{ .path = "src/tests/accumulate_test.zig" },
        .{ .path = "src/tests/bifurcate_by_test.zig" },
        .{ .path = "src/tests/btoa_test.zig" },
    };
    setupTestStep(b, &tests);
}

fn createExecutable(b: *std.Build, name: []const u8, rootSource: []const u8) *std.Build.Step.Compile {
    return b.addExecutable(.{
        .name = name,
        .root_source_file = .{ .cwd_relative = rootSource },
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    });
}

fn setupRunStep(b: *std.Build, run_cmd: *std.Build.Step.Run) void {
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

fn setupTestStep(b: *std.Build, tests: []const TestFile) void {
    const zigonic_module = b.addModule("zigonic", .{
        .root_source_file = .{ .cwd_relative = "src/zigonic.zig" },
    });

    const all_tests_step = b.step("test", "Run all tests");
    for (tests) |test_file| {
        const test_exe = b.addTest(.{
            .root_source_file = .{ .cwd_relative = test_file.path },
        });

        test_exe.root_module.addImport("zigonic", zigonic_module);

        const test_step = b.addRunArtifact(test_exe);
        all_tests_step.dependOn(&test_step.step);
    }
}
