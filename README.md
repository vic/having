# Having

Haskell like `where` sugar for Elixir. A pipe-able `with` special form.

## Usage

```elixir
import Having
```

The `having` macro is a tiny syntax sugar around `with`. To make it work a bit
like the `where` keyword for Haskell, where you can have an expression and
then some bindings for evaling it on.

For example, the following Haskell code

```haskell
a + b
where
  a = 3
  b = a * a
```

Could be written in Elixir like:

```elixir
iex> a + b
...> |> having(a: 3, b: a * a)
12
```

that will be compiled into:

```elixir
with a = 3,
     b = a * a,
do: a + b
```

Every `having` gets rewritten into a corresponding `with` special form.
And thus can have its own `else:` clauses, guards on `<-` just like `with`.

For example if you pipe an expression into two `having`s:

```elixir
{a, b}
|> having(a = b * b)
|> having(b when b < 10 <- 2)
```

will get rewritten to:

```elixir
with(b when b < 10 <- 2) do
  with(a = b * b) do
    {a, b}
  end
end
```

Note that in the `having` example, the expression you want to compute
is the first thing you see, instead of it being nested inside `with` forms.
Also note that the most external `with` corresponds to the latest piped `having`
this is important if you need to have some values that depend on others.


For more examples look at the documentation of [having.ex](https://github.com/vic/having/blob/master/lib/having.ex)

## Installation

[Available in Hex](https://hex.pm/packages/having), the package can be installed as:

  1. Add `having` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:having, "~> 0.1.0"}]
    end
    ```

  2. Ensure `having` is started before your application:

    ```elixir
    def application do
      [applications: [:having]]
    end
    ```

