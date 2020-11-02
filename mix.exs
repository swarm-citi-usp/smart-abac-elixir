defmodule ABACthem.MixProject do
  use Mix.Project

  def project do
    [
      app: :abac_them,
      version: "0.2.1",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_), do: ["lib", "web"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ABACthem.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cbor, "~> 1.0.0"},
      {:ecto, "~> 3.3"},
      {:ex_machina, "~> 2.4", only: :test},
      {:tzdata, "~> 1.0.1"},
      {:jason, "~> 1.2"},
      {:decorator, "~> 1.2"},
      {:poison, "~> 3.1"},
      {:tesla, "~> 1.2.1"}
    ]
  end
end
