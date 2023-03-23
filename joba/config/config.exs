# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :joba,
  ecto_repos: [Joba.Repo]

# Configures the endpoint
config :joba, JobaWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: JobaWeb.ErrorHTML, json: JobaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Joba.PubSub,
  live_view: [signing_salt: "Nk+Udbdh"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :joba, Joba.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.7",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Oban: Job Runner
config :joba, Oban,
  repo: Joba.Repo,
  plugins: [{Oban.Plugins.Pruner, max_age: 3000}],
  queues: [default: 10, parallel: 10, serial: 1]

config :joba, Joba.Scheduler,
  timezone: "America/Los_Angeles",
  global: false,
  jobs: [
    # {"* * * * *", fn -> System.cmd("uptime", []) end},
    {"* * * * *", {Joba.Job, :serial,   ["sleep20", "sleep 20"]}}
    # {"* * * * *", {Joba.Job, :parallel, ["sleep40", "sleep 40"]}}
    # {"* * * * *", {Joba.Job.Parallel, args: %{type: "sleep30", cmd: "sleep 30; date"}}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
