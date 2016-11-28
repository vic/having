defmodule Having.Pipe do

  defmacro a | b, do: Having.having_pipe(a, b)

end
