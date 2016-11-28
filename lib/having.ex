defmodule Having do

  @moduledoc ~S"""
      iex> import Having
      iex> having({a, b}, a: 1, b: 2)
      {1, 2}

      iex> import Having
      iex> {a, b} |> having(a: 1, b: 2)
      {1, 2}

      iex> import Having
      iex> a + b
      ...> |> having(a: b * b, b: 3)
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

  """

  defmacro having(expr) do
    having_fun(expr, [], [])
  end

  defmacro having(expr, opts) do
    having_piped(expr, opts)
  end

  def having_pipe(a, b) do
    having_fun({:|, [], [a, b]}, [], [])
  end

  defp having_piped(expr, opts) do
    opts = if Keyword.keyword?(opts) do opts else [do: opts] end
    {binds, elses} = having_do_else(opts)
    having_fun(expr, binds, elses)
  end

  defp having_fun(expr, binds, elses) do
    {expr, binds, elses} = having_binds(expr, binds, elses)
    binds = Enum.reverse(binds)
    does  = [do: expr]
    elses = if length(elses) > 0 do [else: elses] else [] end
    {:with, [], binds ++ [does ++ elses]}
  end

  defp having_binds({x, _, [a, {:with, _, b}]}, binds, elses) when x == :|> or x == :| do
    binds = (b ++ binds) |> Enum.reverse
    {a, binds, elses}
  end

  defp having_binds({:having, _, [a, b]}, binds, elses) do
    expr = having_piped(a, b)
    {expr, binds, elses}
  end

  defp having_binds({:|, _, [a, b]}, binds, elses) do
    {b_binding, binds, elses} = having_binds(b, binds, elses)
    {a, [b_binding | binds], elses}
  end

  defp having_binds(x, binds, elses) do
    {x, binds, elses}
  end

  defp having_block(opts, key) do
    opts
    |> Keyword.get(key)
    |> case do
         nil -> []
         {:__block__, _, does} -> does
         does -> List.wrap(does)
       end
  end

  defp kw_to_binds(kw) do
    Enum.map kw, fn {key, value} ->
      {:=, [], [{key, [], nil}, value]}
    end
  end

  defp having_do_else(opts) do
    does = having_block(opts, :do)
    elses = having_block(opts, :else)
    binds = opts |> Keyword.drop([:do, :else]) |> kw_to_binds
    {binds ++ does, elses}
  end

end
