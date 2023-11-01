const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zigonic",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const tests = [_][]const u8{
        "src/tests/all_of_test.zig",
        "src/tests/max_element_test.zig",
    };

    const zigonicmodule = b.createModule(.{
        .source_file = std.Build.LazyPath.relative("src/zigonic.zig"),
    });

    const all_tests_step = b.step("test", "Run all tests");
    for (tests, 0..) |test_file, i| {
        _ = i;
        const test_exe = b.addTest(.{
            .root_source_file = .{ .path = test_file },
            .target = target,
            .optimize = optimize,
        });
        test_exe.addModule("zigonic", zigonicmodule);
        const test_step = b.addRunArtifact(test_exe);
        all_tests_step.dependOn(&test_step.step);
    }
}
