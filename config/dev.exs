use Mix.Config

config :jobex_web, JobexWeb.Endpoint,
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
      cd: Path.expand("../apps/jobex_web/assets", __DIR__)
    ]
  ]

config :logger, level: :info

# Watch static and templates for browser reloading.
config :jobex_web, JobexWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/jobex_web/{live,views}/.*(ex)$",
      ~r"lib/jobex_web/templates/.*(eex)$"
    ]
  ]

# Configure your database
config :jobex_data, JobexData.Repo,
  username: "postgres",
  password: "postgres",
  database: "jobex_data_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
