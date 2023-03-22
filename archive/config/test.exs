use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :jobex_ui, JobexUi.Endpoint,
  http: [port: 4002],
  server: false

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :jobex_ui, JobexUi.Endpoint,
  http: [port: 4002],
  server: false

config :jobex_web, JobexWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :error

config :jobex_core, JobexCore.Repo,
  username: "postgres",
  password: "postgres",
  database: "jobex_core_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

  config :jobex_core, Oban, 
  queues: false, 
  prune: :disabled
