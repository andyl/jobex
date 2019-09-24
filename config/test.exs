use Mix.Config

config :jobex_web, JobexWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :info

config :jobex_data, JobexData.Repo,
  username: "postgres",
  password: "postgres",
  database: "jobex_data_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

  config :jobex_data, Oban, 
  queues: false, 
  prune: :disabled
