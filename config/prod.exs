import Config

config :jobex, JobexWeb.Endpoint,
  url: [host: "localhost", port: 5070],
  cache_static_manifest: "priv/static/cache_manifest.json",
  check_origin: false,
  server: true,
  root: "."

config :logger, level: :info

config :jobex, JobexWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "5070")],
  url: [scheme: "http"],
  check_origin: false,
  secret_key_base: "_123456789_123456789_123456789_123456789_123456789_123456789_123456789"

config :jobex, JobexCore.Repo,
  username: "postgres",
  password: "postgres",
  database: "jobex_prod",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

