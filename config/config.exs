import Config

config :jobex_web,  :env, Mix.env()
config :jobex_data, :env, Mix.env()

config :jobex_web,
  generators: [context_app: false]

config :jobex_web, JobexWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "QS8kX5FCVfibbmDoqgt4hvDjBg8ibIX6GB4Nu8uwaCCrklexWWHBhZ9Z39TA4c4z",
  render_errors: [view: JobexWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: JobexWeb.PubSub, adapter: Phoenix.PubSub.PG2]

config :jobex_data,
  ecto_repos: [JobexData.Repo]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :jobex_web, JobexWeb.Endpoint, live_view: [signing_salt: "asdf"]

config :jobex_data, Oban,
  repo: JobexData.Repo,
  prune: {:maxlen, 5_000},
  crontab: [
    # {"* * * * *", JobexData.Worker.Test}
    # {"* * * * *", JobexData.Worker.Parallel, args: %{type: "sleep30", cmd: "sleep 30; date"}}
  ],
  queues: [default: 10, parallel: 10, serial: 1]

config :jobex_data, JobexData.Scheduler,
  timezone: "America/Los_Angeles",
  global: false,
  jobs: []

import_config "#{Mix.env()}.exs"
