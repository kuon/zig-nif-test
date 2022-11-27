const std = @import("std");
const Pkg = std.build.Pkg;

pub fn build(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();

    const nif_step = b.step("nif_lib", "Compiles erlang library");
    const nif_lib = b.addSharedLibrary("nif_test", "./src/main.zig", .unversioned);
    nif_lib.setBuildMode(mode);
    nif_lib.setOutputDir("build");
    nif_lib.addIncludePath("/usr/lib/erlang/usr/include/");

    nif_lib.install();
    nif_lib.linkLibC();
    nif_step.dependOn(&nif_lib.step);
}
