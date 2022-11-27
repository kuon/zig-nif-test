// Load zig standard library, here we need it for debug print to stderr
const std = @import("std");

// Load ERL library header
const erl = @cImport({
    @cInclude("erl_nif.h");
});

// Declare a NIF function
// Every function in your module will have the same zig signature
export fn foo_test(
    // This is the erlang environment, we need this for all NIF operations
    env: ?*erl.ErlNifEnv,
    // The number of argument your function was called with
    argc: c_int,
    // An array of arguments
    argv: [*c]const erl.ERL_NIF_TERM,
) erl.ERL_NIF_TERM { // Returned value is also a erlang term
    // Our test function is going to accept a single argument, a binary
    // We need to allocate the stack for it
    var test_binary: erl.ErlNifBinary = undefined;

    // We check that we have one argument and that we can transform this
    // argument into a binary, a binary is just a serie of bytes
    if ((argc != 1) or
        // we try to convert the argument at position 0 into a binary
        (erl.enif_inspect_binary(env, argv[0], &test_binary) != 1))
    {
        // If it fails, we return a bad argument error
        return erl.enif_make_badarg(env);
    }
    // If we are here, it's a success, we got our binary
    // Note that the binary data contained into `test_binary` will be
    // deallocated when this function returns
    // If you want to keep it longer, you need top copy it
    //
    // What we do here is that we build a slice and point it to the binary
    // this does NOT copy any data and this slice would be invalid after this
    // function returns
    //
    // Create an empty slice (pointer + len)
    var test_slice: []const u8 = &.{};
    // Set len
    test_slice.len = test_binary.size;
    // Set ptr
    test_slice.ptr = test_binary.data;

    // Now our slice is printable as a C string by zig formatter
    // This prints to stderr by default
    std.debug.print("Test slice: {s}\n\n", .{test_slice});

    // We return an int, 2, to demonstrate how to return data
    return erl.enif_make_int(env, 2);
}


// How many functions will our module have?
const func_count = 1;

// Create an array of function
var funcs = [func_count]erl.ErlNifFunc{
    // Our test function
    erl.ErlNifFunc{
        // The erlang/elixir name, this must match the name in the module
        .name = "foo_test",
        // The arity, note that you can declare multiple functions with same
        // name and different arity
        .arity = 1,
        // The function implementation, this must match the name in the zig code
        // above.
        // You can use the same zig function for multiple arity, thus the
        // argc argument to the zig function
        .fptr = foo_test,
        // Flags can be set to mark the function as dirty
        // Dirty functions can take more CPU time
        // Regular function must be fast, <1 ms
        // You can set this to erl.ERL_NIF_DIRTY_JOB_CPU_BOUND or
        // erl.ERL_NIF_DIRTY_JOB_IO_BOUND
        .flags = 0,
    },
};


// All the following code is required because it is implemented as macro in the
// C version With C, you just call the magic macro ERL_NIF_INIT
// but we cannot do that in zig, so here is a full manual implementation

// This is the NIF entry for out module
var entry = erl.ErlNifEntry{
    // We just the version of the header
    .major = erl.ERL_NIF_MAJOR_VERSION,
    .minor = erl.ERL_NIF_MINOR_VERSION,
    // If this is an elixir module that will be available as `NifTest`
    // on the elixir side, we need to add `Elixir` in front of it
    .name = "Elixir.NifTest",
    // Hor many functions
    .num_of_funcs = func_count,
    // Pointer to function definition array
    .funcs = &funcs,
    // Callbacks for the lifecycle of our NIF, they can be nil
    .load = null,
    .reload = null,
    .upgrade = null,
    .unload = null,
    // Which VM variant
    .vm_variant = "beam.vanilla",
    // This can be erl.ERL_NIF_DIRTY_NIF_OPTION 
    .options = 0,
    // This must be defined as is
    .sizeof_ErlNifResourceTypeInit = @sizeOf(erl.ErlNifResourceTypeInit),
    // Minimum erts version
    .min_erts = "erts-10.4",
};

// This is the function that will be called by the erlang runtime when loading
// the module
export fn nif_init() *erl.ErlNifEntry {
    return &entry;
}
