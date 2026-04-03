defmodule Jobex.MixProject do
  use Mix.Project

  def project do
    [
      app: :jobex,
      version: "0.0.1",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      deb_package: deb_package()
    ]
  end

  def application do
    [
      mod: {Jobex.Application, []},
      extra_applications: [:logger, :runtime_tools, :timex, :phoenix_html_simplified_helpers]
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
      {:modex, path: "~/src/modex"},
      # ----- csv parsing
      {:nimble_csv, "~> 1.1"},
      # ----- jobs
      {:oban, "~> 2.5"},
      {:quantum, "~> 3.3"},
      {:timex, "~> 3.0"},
      # ----- pubsub
      {:phoenix_pubsub, "~> 2.0"},
      # ----- phoenix backend
      {:phoenix, "~> 1.5"},
      {:plug_cowboy, "~> 2.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_html_simplified_helpers, "~> 2.1.0"},
      # ----- phoenix view helpers
      {:phoenix_active_link, "~> 0.3.0"},
      {:phoenix_live_view, "~> 0.15"},
      # ----- i18n
      {:gettext, "~> 0.11"},
      # ----- monitoring
      # {:observer_cli, "~> 1.5"},
      # ----- development and test
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:ex_projections, github: "andyl/ex_projections", only: :dev, runtime: false},
      # ----- deployment
      {:distillery, "~> 2.1", warn_missing: false}
    ]
  end

  def deb_package do
   [
      vendor: "Andy Leak",
      maintainers: ["AndyL <andy@r210.com>"],
      homepage: "NA",
      base_path: "/opt",
      external_dependencies: [],
      maintainer_scripts: [
         pre_install: "rel/distillery_packager/debian/install_scripts/pre_install.sh",
         post_install: "rel/distillery_packager/debian/install_scripts/post_install.sh",
         pre_uninstall: "rel/distillery_packager/debian/install_scripts/pre_uninstall.sh"
      ],
      config_files: ["/etc/init/.conf"],
      additional_files: [{"configs", "/etc/distillery_packager/configs"}],
      owner: [user: "root", group: "root"]
   ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
