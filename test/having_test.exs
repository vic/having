defmodule HavingTest do
  use ExUnit.Case

  import Having.TestHelper
  import Having

  doctest Having

  test "simple expression with binding" do
    assert 1 = having a
    | a = 1
  end

  test "expands simple expression with binding" do
    actual = expanded do
      having a
      | a = 1
    end
    expected = quoted do
      with(a = 1, do: a)
    end
    assert expected == actual
  end

  test "expands two bindings into single with" do
    actual = expanded do
      having {a, b}
      | a = 1
      | b = 2
    end
    expected = quoted do
      with(b = 2, a = 1, do: {a, b})
    end
    assert expected == actual
  end

  test "expands three bindings into single with" do
    actual = expanded do
      having {b, c}
      | c = b * b
      | b = a * a
      | a = 2
    end
    expected = quoted do
      with(a = 2, b = a * a, c = b * b, do: {b, c})
    end
    assert expected == actual
  end

  defp pows(x), do: having {m, n}
  | n = m * m
  | m = x * x

  test "using having on a function def" do
    assert {4, 16} = pows(2)
  end

  test "can use match" do
    actual = expanded do
      having a
      |( a when is_number(a) <- 1 )
    end
    expected = quoted do
      with(a when is_number(a) <- 1) do
        a
      end
    end
    assert expected == actual
  end

  test "can be piped into" do
    actual = expanded do
      {a, b}
      |> having do
        a = 1
        b = 2
      end
    end
    expected = quoted do
      with(b = 2, a = 1, do: {a, b})
    end
    assert expected == actual
  end

  test "can pipe into keywords" do
    actual = expanded do
      {a, b} |> having(a: 1, b: 2)
    end
    expected = quoted do
      with(b = 2, a = 1, do: {a, b})
    end
    assert expected == actual
  end

  test "can have else on piped having" do
    actual = expanded do
      a
      |> having do
        b
      else
        _ -> c
      end
    end
    expected = quoted do
      with(b) do
        a
      else
        _ -> c
      end
    end
    assert expected == actual
  end

  test "nested piped having" do
    actual = expanded do
      a
      |> having(b when b < 10 <- 2)
      |> having(c = 2)
    end
    expected = quoted do
      with(c = 2) do
        with(b when b < 10 <- 2) do
          a
        end
      end
    end
    assert expected == actual
  end

  test "nested piped having else" do
    actual = expanded do
      a
      |> having do
        b
      else
        _ -> x
      end
      |> having(c)
    end
    expected = quoted do
      with(c) do
        with(b) do
          a
        else
          _ -> x
        end
      end
    end
    assert expected == actual
  end

  test "pipes into with" do
    actual = expanded do
      having a
      |> with(b, c)
    end
    expected = quoted do
      with(b, c) do
        a
      end
    end
    assert expected == actual
  end


end
