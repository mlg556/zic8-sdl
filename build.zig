const std = @import("std");
const zsdl = @import("deps/zig-gamedev/libs/zsdl/build.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zake8-sdl",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const zsdl_pkg = zsdl.package(b, target, optimize, .{});
    zsdl_pkg.link(exe);

    const zic8 = b.addModule("zic8", .{ .source_file = .{ .path = "libs/zic8/zic8.zig" } });
    exe.addModule("zic8", zic8);

    // exe.addAnonymousModule("zigimg", .{ .source_file = .{ .path = "libs/zigimg/zigimg.zig" } });

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
