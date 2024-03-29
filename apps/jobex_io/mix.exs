defmodule JobexIo.MixProject do
  use Mix.Project

  def project do
    [
      app: :jobex_io,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {JobexIo.Application, []}
    ]
  end

  defp deps do
    [
      {:phoenix_pubsub, "~> 2.0"}
    ]
  end
end
