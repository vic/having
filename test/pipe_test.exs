defmodule Having.PipeTest do
  use ExUnit.Case

  import Having.TestHelper
  import Having.Pipe

  doctest Having.Pipe

  test "pipe expands to with" do
    actual = expanded do
      a
      | a = 1
    end
    expected = expanded do
      with(a = 1, do: a)
    end
    assert expected == actual
  end

  test "expands two bindings into single with" do
    actual = expanded do
      {a, b}
      | a = 1
      | b = 2
    end
    expected = quoted do
      with(b = 2, a = 1, do: {a, b})
    end
    assert expected == actual
  end

end
