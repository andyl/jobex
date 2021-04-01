use Mix.Config

# ----- JobexUi

config :jobex_ui, JobexUi.Endpoint,
  http: [port: 4075],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../apps/jobex_ui/assets", __DIR__)
    ]
  ]

config :jobex_ui, JobexUi.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/jobex_ui/(live|views)/.*(ex)$",
      ~r"lib/jobex_ui/templates/.*(eex)$"
    ]
  ]

# ----- JobexWeb

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

config :jobex_web, JobexWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/jobex_web/{live,views}/.*(ex)$",
      ~r"lib/jobex_web/templates/.*(eex)$"
    ]
  ]

# ----- JobexCore

config :jobex_core, JobexCore.Repo,
  username: "postgres",
  password: "postgres",
  database: "jobex_core_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# ----- Misc

config :logger, level: :info
