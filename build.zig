const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("isocline", .{
        .root_source_file = b.path("src/isocline.zig"),
        .target = target,
        .optimize = optimize,
    });
    module.addCSourceFile(.{ .file = b.path("src/isocline.c") });
}
