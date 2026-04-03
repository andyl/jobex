import Config

config :jobex, JobexWeb.Endpoint,
  http: [port: 4070],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:jobex, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:jobex, ~w(--watch)]}
  ]

config :jobex, JobexWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/jobex_web/(controllers|live|components)/.*(ex|heex)$"
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

config :phoenix, :plug_init_mode, :runtime
