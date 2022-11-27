
.PHONY: run

run: build/libnif_test.so
	@elixir runner.ex


build/libnif_test.so: src/main.zig build.zig
	zig build nif_lib

.PHONY: clean

clean:
	rm -fr build zig-cache zig-out
