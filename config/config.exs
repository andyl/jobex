import Config

config :jobex, :env, Mix.env()

config :jobex,
  generators: [context_app: false]

config :jobex, JobexWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "QS8kX5FCVfibbmDoqgt4hvDjBg8ibIX6GB4Nu8uwaCCrklexWWHBhZ9Z39TA4c4z",
  render_errors: [view: JobexWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: JobexWeb.PubSub,
  live_view: [signing_salt: "FnCl0cD24kFBQQZBsupersecretandlong"]

config :jobex,
  ecto_repos: [JobexCore.Repo]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :jobex, Oban,
  repo: JobexCore.Repo,
  queues: [default: 10, parallel: 10, serial: 1]

config :jobex, JobexCore.Scheduler,
  timezone: "America/Los_Angeles",
  global: false,
  jobs: [
    {"* * * * *", {JobexCore.Job, :serial,   ["sleep20", "sleep 20"]}}
  ]

import_config "#{Mix.env()}.exs"
