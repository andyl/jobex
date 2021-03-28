defmodule JobexCore.MixProject do
  use Mix.Project

  def project do
    [
      app: :jobex_core,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {JobexCore.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # ----- database
      {:ecto_sql, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.0"},
      # ----- process execution
      {:porcelain, "~> 2.0"},
      {:rambo, "~> 0.2"},
      # ----- utility functions 
      {:modex,     path: "~/src/modex"},
      # ----- csv parsing -----
      {:nimble_csv, "~> 1.1"},
      # ----- jobs
      {:oban,      "~> 0.12"},
      {:quantum,   "~> 2.3"},
      {:timex,     "~> 3.0"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
