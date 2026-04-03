import Config

config :jobex, JobexWeb.Endpoint,
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
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

config :jobex, JobexWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/jobex_web/{live,views}/.*(ex)$",
      ~r"lib/jobex_web/templates/.*(eex)$"
    ]
  ]

config :jobex, JobexCore.Repo,
  username: "postgres",
  password: "postgres",
  database: "jobex_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :logger, level: :debug
