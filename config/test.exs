use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :crow_web, CrowWeb.Endpoint,
  http: [port: 4002],
  server: false

# Configure your database
config :crow_data, CrowData.Repo,
  username: "postgres",
  password: "postgres",
  database: "crow_data_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
