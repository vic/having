defmodule Having.TestHelper do

  defmacro quoted([do: expr]) do
    expr
    |> Macro.prewalk(&Macro.update_meta(&1, fn _ -> [] end))
    |> Macro.escape
  end

  defmacro expanded([do: expr]) do
    Macro.expand(expr, __CALLER__)
    |> Macro.prewalk(&Macro.update_meta(&1, fn _ -> [] end))
    |> Macro.escape
  end

end

ExUnit.start()
