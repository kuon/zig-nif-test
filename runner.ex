Code.require_file("nif_test.ex")

ret = NifTest.foo_test("Hello world")

IO.puts("We got #{ret} from NIF")
