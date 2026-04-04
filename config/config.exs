import Config

config :jobex, :env, Mix.env()

config :jobex,
  generators: [context_app: false]

config :jobex, JobexWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "QS8kX5FCVfibbmDoqgt4hvDjBg8ibIX6GB4Nu8uwaCCrklexWWHBhZ9Z39TA4c4z",
  render_errors: [formats: [html: JobexWeb.ErrorHTML, json: JobexWeb.ErrorJSON], layout: false],
  pubsub_server: JobexWeb.PubSub,
  live_view: [signing_salt: "FnCl0cD24kFBQQZBsupersecretandlong"]

config :jobex,
  ecto_repos: [JobexCore.Repo]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :elixir, :time_zone_database, Tz.TimeZoneDatabase

config :esbuild,
  version: "0.25.0",
  jobex: [
    args: ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "4.1.4",
  jobex: [
    args: ~w(
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :jobex, Oban,
  repo: JobexCore.Repo,
  queues: [default: 10, parallel: 10]

config :jobex, JobexCore.Scheduler,
  timezone: "America/Los_Angeles",
  global: false,
  jobs: [
    {"* * * * *", {JobexCore.Job, :serial,   ["sleep20", "sleep 20"]}}
  ]

import_config "#{Mix.env()}.exs"
