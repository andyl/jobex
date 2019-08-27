defmodule CrowWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :crow_web,
      version: "0.0.1",
      elixir: "~> 1.9",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {CrowWeb.Application, []},
      extra_applications: [:logger, :runtime_tools, :timex, :phoenix_html_simplified_helpers]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # ----- phoenix backend
      {:phoenix, "~> 1.4.6"},
      {:plug_cowboy, "~> 2.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_html_simplified_helpers, "~> 2.1.0"},
      # ----- phoenix view helpers
      {:phoenix_active_link, "~> 0.2.1"},
      {:phoenix_live_view, github: "phoenixframework/phoenix_live_view"},
      # ----- util
      {:jason, "~> 1.0"},
      {:gettext, "~> 0.11"},
      {:timex, "~> 3.1"},
      # ----- monitoring and tracing
      {:observer_cli, "~> 1.5"},
      # ----- development and test
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      # ----- data
      {:crow_data, in_umbrella: true}
    ]
  end
end
