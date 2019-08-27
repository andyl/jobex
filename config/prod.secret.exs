use Mix.Config

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :crow_web, CrowWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "5030")],
  secret_key_base: secret_key_base

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :crow_data, CrowData.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
