defmodule Jobex.MixProject do
  use Mix.Project

  @version "0.0.7"

  def project do
    [
      app: :jobex,
      version: @version,
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: [
        jobex: [
          steps: [:assemble, :tar],
          include_executables_for: [:unix]
        ]
      ],
      usage_rules: usage_rules(),
      listeners: [Phoenix.CodeReloader],
    ]
  end

  def application do
    [
      mod: {Jobex.Application, []},
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
      {:modex, path: "~/src/modex"},
      # ----- csv parsing
      {:nimble_csv, "~> 1.1"},
      # ----- jobs
      {:oban, "~> 2.19"},
      {:quantum, "~> 3.3"},
      # ----- pubsub
      {:phoenix_pubsub, "~> 2.0"},
      # ----- phoenix backend
      {:phoenix, "~> 1.8"},
      {:plug_cowboy, "~> 2.0"},
      {:phoenix_html, "~> 4.3"},
      {:phoenix_html_helpers, "~> 1.0"},
      {:phoenix_ecto, "~> 4.7"},
      # ----- phoenix liveview
      {:phoenix_live_view, "~> 1.1"},
      # ----- timezone
      {:tz, "~> 0.28.1"},
      # ----- i18n
      {:gettext, "~> 1.0"},
      # ----- monitoring
      # {:observer_cli, "~> 1.5"},
      # ----- UI
      {:tailwind, "~> 0.4.1", runtime: Mix.env() == :dev},
      {:phoenix_live_reload, "~> 1.6", only: :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      # ----- ops
      {:commit_hook, "~> 0.4"},
      {:igniter, "~> 0.6"},
      {:ziprel, path: "~/src/Tool/ziprel"},
      {:git_ops, "~> 2.0", only: [:dev], runtime: false},
      # ----- development and test
      {:esbuild, "~> 0.10.0", runtime: Mix.env() == :dev},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:ex_projections, github: "andyl/ex_projections", only: :dev, runtime: false},
      {:live_debugger, "~> 0.7", only: :dev},
      # ----- AI
      {:tidewave, "~> 0.5", only: :dev},
      {:usage_rules, "~> 1.2", only: [:dev, :test]},
    ]
  end

  defp usage_rules do
    [
      file: "RULES.md",
      usage_rules: [{~r/.*/, link: :markdown}],
      skills: [
        location: ".claude/skills",
        build: []
      ]
    ]
  end

  # def deb_package do
  #  [
  #     vendor: "Andy Leak",
  #     maintainers: ["AndyL <andy@r210.com>"],
  #     homepage: "NA",
  #     base_path: "/opt",
  #     external_dependencies: [],
  #     maintainer_scripts: [
  #        pre_install: "rel/distillery_packager/debian/install_scripts/pre_install.sh",
  #        post_install: "rel/distillery_packager/debian/install_scripts/post_install.sh",
  #        pre_uninstall: "rel/distillery_packager/debian/install_scripts/pre_uninstall.sh"
  #     ],
  #     config_files: ["/etc/init/.conf"],
  #     additional_files: [{"configs", "/etc/distillery_packager/configs"}],
  #     owner: [user: "root", group: "root"]
  #  ]
  # end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind jobex", "esbuild jobex"],
      "assets.deploy": ["tailwind jobex --minify", "esbuild jobex --minify", "phx.digest"]
    ]
  end
end
