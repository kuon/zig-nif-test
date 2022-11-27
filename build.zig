const std = @import("std");
const Pkg = std.build.Pkg;

pub fn build(b: *std.build.Builder) void {

    // Add a build step, this will now be callable with `zig build nif_lib`
    // Steps are optional, you can ommit it, and `zig build` will invoque it
    const nif_step = b.step("nif_lib", "Compiles erlang library");
    // Create a shared library, the output name will have `lib` and `.so` added to it
    // It is not versioned as we will usually use elixir package versioning
    // instead, and we do not plan to distribute the library by itself
    const nif_lib = b.addSharedLibrary("nif_test", "./src/main.zig", .unversioned);

    const mode = b.standardReleaseOptions();
    // Use release mode
    nif_lib.setBuildMode(mode);

    // Override build dir, this is a convention of mine as it plays well with
    // IDE, but the default `zig-out` is fine
    nif_lib.setOutputDir("build");

    // We need to tell zig where to find the erlang headers
    nif_lib.addIncludePath("/usr/lib/erlang/usr/include/");

    // As erlang nif library is in C, we need this
    nif_lib.linkLibC();

    // Install the lib inside the
    nif_lib.install();
    nif_step.dependOn(&nif_lib.step);
}
