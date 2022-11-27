defmodule NifTest do
  # This is called when the module is loaded
  # It is important to call load_nifs from within the module, as
  # NIF can only be loaded within the module it will populate
  @on_load :load_nifs

  def load_nifs do
    # In a real nif, you would adjust this path
    # Second argument is what you C code will receive, we are ignoring it
    # so just pass 0 which is NULL on the C side
    :erlang.load_nif('./build/libnif_test', 0)
  end

  # Our first function, it needs to have the same name and arity as C version
  # Implementation is not important, but it is good manner to raise
  # if tthe NIF is not loaded.
  # The NIF version will come override this one.
  def foo_test(_a) do
    raise "NIF foo_test/1 not implemented"
  end
end
