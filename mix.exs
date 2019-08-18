defmodule Crow.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.0.1",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  # def application do
  #   [
  #     mod: {Crow.Application, []},
  #     extra_applications: [:logger, :runtime_tools, :timex]
  #   ]
  # end

  # Specifies which paths to compile per environment.
  # defp elixirc_paths(:test), do: ["lib", "test/support"]
  # defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # ----- deployment
      {:distillery, "~> 2.1", warn_missing: false},
      # ----- development and test
      {:mix_test_watch, "~> 0.8", only: :dev}
    ]
  end
end
