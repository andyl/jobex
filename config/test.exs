import Config

config :jobex, JobexWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :error

config :jobex, JobexCore.Repo,
  username: "postgres",
  password: "postgres",
  database: "jobex_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :jobex, Oban,
  queues: false
