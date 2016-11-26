defmodule Having do

  @moduledoc ~S"""
  """

  @doc ~S"""
      iex> import Having
      iex> having({a, b}, a: 1, b: 2)
      {1, 2}


      iex> import Having
      iex> {a, b} |> having(a: 1, b: 2)
      {1, 2}


      iex> import Having
      iex> a + b
      ...> |> having(b: 3, a: b * b)
      12

      iex> import Having
      iex> {a, b}
      ...> |> having do
      ...>   a <- 1
      ...>   b <- 2
      ...> end
      {1, 2}

      iex> import Having
      iex> {a, b}
      ...> |> having do
      ...>   {:ok, a} <- 1
      ...>   b <- 2
      ...> else
      ...>   _ -> :nop
      ...> end
      :nop

      iex> import Having
      iex> {a, b}
      ...> |> having(a <- b * 2)
      ...> |> having(b = 10)
      {20, 10}

      iex> import Having
      iex> {a, b}
      ...> |> having do
      ...>     a when a > 10 <- b
      ...>   else
      ...>     _ -> {:error, b}
      ...>   end
      ...> |> having(b = 10)
      {:error, 10}

      iex> import Having
      iex> {a, b}
      ...> |> having(a when a > 10 <- b, {:error, b})
      ...> |> having(b = 10)
      {:error, 10}

  """
  defmacro having(expr, options)

  defmacro having(expr, opts) do
    opts = Keyword.keyword?(opts) && opts || [do: opts]
    bindings = opts |> Keyword.drop([:do, :else]) |> kw_to_bindings
    bindings =
      Keyword.get(opts, :do)
      |> case do
        nil -> bindings
        {:__block__, _, does} -> bindings ++ does
        does -> bindings ++ List.wrap(does)
      end
    elses = Keyword.get(opts, :else)
    {:with, [], bindings ++ [[do: expr]] ++ [elses && [else: elses] || []]}
  end

  @doc false
  defmacro having(expr, binding = {:<-, _, _}, else_expr) do
    quote do
      with(unquote(binding)) do
        unquote(expr)
      else
        _ -> unquote(else_expr)
      end
    end
  end

  defp kw_to_bindings(kw) do
    Enum.map kw, fn {key, value} ->
      {:=, [], [{key, [], nil}, value]}
    end
  end

end
