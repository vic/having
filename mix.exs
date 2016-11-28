defmodule Having.Mixfile do
  use Mix.Project

  def project do
    [app: :having,
     version: "0.1.0",
     elixir: "~> 1.3",
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     elixirc_paths: elixirc_paths(Mix.env),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  def description do
    """
    Haskell like `where` sugar for Elixir. A pipe-able `with` special form.
    """
  end

  defp package do
    [files: ["lib", "mix.exs", "README*"],
     maintainers: ["Victor Borja"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/vic/having"}]
  end

end
