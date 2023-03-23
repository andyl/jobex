defmodule JobexCore.MixProject do
  use Mix.Project

  def project do
    [
      app: :jobex_core,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {JobexCore.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # ----- phoenix
      {:phoenix, "~> 1.7.2"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_view, "~> 0.18"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.7.2"},
      {:floki, ">= 0.30.0", only: :test},
      # ----- comms
      {:swoosh, "~> 1.3"},
      {:finch, "~> 0.13"},
      # ----- assets
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      # ----- ecto
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      # ----- csv parsing -----
      {:nimble_csv, "~> 1.1"},
      # ----- job scheduling and execution
      {:oban, "~> 2.14"},
      {:quantum, "~> 3.0"},
      # ----- process execution
      {:porcelain, "~> 2.0"},
      {:rambo, "~> 0.3"},
      # ----- metrics
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      # ----- misc
      {:plug_cowboy, "~> 2.5"},
      {:gettext, "~> 0.20"},
      {:timex, "~> 3.7"},
      {:modex, github: "andyl/modex"},
      {:bcrypt_elixir, "~> 3.0"},
      {:jason, "~> 1.2"},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
