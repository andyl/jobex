defmodule Crow.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.0.1",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      deb_package: deb_package()
    ]
  end

  defp deps do
    [
      # ----- deployment
      {:distillery, "~> 2.1", warn_missing: false},
      # {:distillery_packager, "~> 1.0"},
      # ----- development and test
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false},
      {:ex_projections, github: "andyl/ex_projections", only: :dev, runtime: false}
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
