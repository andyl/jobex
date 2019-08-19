use Mix.Config

config :crow_web, CrowWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :info

config :crow_data, CrowData.Repo,
  username: "postgres",
  password: "postgres",
  database: "crow_data_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

  config :crow_data, Oban, 
  queues: false, 
  prune: :disabled
