import Config

config :jobex_web,  :env, Mix.env()
config :jobex_core, :env, Mix.env()

config :jobex_web,
  generators: [context_app: false]

config :jobex_web, JobexWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "QS8kX5FCVfibbmDoqgt4hvDjBg8ibIX6GB4Nu8uwaCCrklexWWHBhZ9Z39TA4c4z",
  render_errors: [view: JobexWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: JobexWeb.PubSub,
  live_view: [signing_salt: "FnCl0cD24kFBQQZBsupersecretandlong"]

config :jobex_core,
  ecto_repos: [JobexCore.Repo]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

# config :jobex_web, JobexWeb.Endpoint, live_view: [signing_salt: "asdf"]

config :jobex_core, Oban,
  repo: JobexCore.Repo,
  # prune: {:maxlen, 5_000},
  # this feature was moved to PRO - $39/month
  crontab: [
    # {"* * * * *", JobexCore.Worker.Test}
    # {"* * * * *", JobexCore.Worker.Parallel, args: %{type: "sleep30", cmd: "sleep 30; date"}}
  ],
  queues: [default: 10, parallel: 10, serial: 1]

config :jobex_core, JobexCore.Scheduler,
  timezone: "America/Los_Angeles",
  global: false,
  jobs: []

import_config "#{Mix.env()}.exs"
