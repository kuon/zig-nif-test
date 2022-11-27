const std = @import("std");
const erl = @cImport({
    @cInclude("erl_nif.h");
});

export fn foo_test(
    env: ?*erl.ErlNifEnv,
    argc: c_int,
    argv: [*c]const erl.ERL_NIF_TERM,
) erl.ERL_NIF_TERM {
    var test_binary: erl.ErlNifBinary = undefined;

    if ((argc != 1) or
        (erl.enif_inspect_binary(env, argv[0], &test_binary) != 1))
    {
        return erl.enif_make_badarg(env);
    }
    var test_slice: []const u8 = &.{};
    test_slice.len = test_binary.size;
    test_slice.ptr = test_binary.data;

    std.debug.print("Test slice: {s}\n\n", .{test_slice});

    return erl.enif_make_int(env, 2);
}

const func_count = 1;

var funcs = [func_count]erl.ErlNifFunc{
    erl.ErlNifFunc{
        .name = "foo_test",
        .arity = 1,
        .fptr = foo_test,
        .flags = 0,
    },
};

var entry = erl.ErlNifEntry{
    .major = erl.ERL_NIF_MAJOR_VERSION,
    .minor = erl.ERL_NIF_MINOR_VERSION,
    .name = "Elixir.NifTest",
    .num_of_funcs = func_count,
    .funcs = &funcs,
    .load = null,
    .reload = null,
    .upgrade = null,
    .unload = null,
    .vm_variant = "beam.vanilla",
    .options = 1,
    .sizeof_ErlNifResourceTypeInit = @sizeOf(erl.ErlNifResourceTypeInit),
    .min_erts = "erts-10.4",
};

export fn nif_init() *erl.ErlNifEntry {
    return &entry;
}
