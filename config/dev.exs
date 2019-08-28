use Mix.Config

config :crow_web, CrowWeb.Endpoint,
  http: [port: 4070],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../apps/crow_web/assets", __DIR__)
    ]
  ]

config :logger, level: :info

# Watch static and templates for browser reloading.
config :crow_web, CrowWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/crow_web/{live,views}/.*(ex)$",
      ~r"lib/crow_web/templates/.*(eex)$"
    ]
  ]

# Configure your database
config :crow_data, CrowData.Repo,
  username: "postgres",
  password: "postgres",
  database: "crow_data_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
