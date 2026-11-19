defmodule TrollWatch.MixProject do
  use Mix.Project

  def project do
    [
      app: :troll_watch,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {TrollWatch.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bandit, "~> 1.15.0"},
      {:cors_plug, "~> 3.0.3"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:finch, "~> 0.25.0"},
      {:floki, "~> 0.38.0"},
      {:jason, "~> 1.4.5"},
      {:plug, "~> 1.20.4"}
    ]
  end
end
