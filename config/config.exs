import Config

config :crow_web,
  generators: [context_app: false]

config :crow_web, CrowWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "QS8kX5FCVfibbmDoqgt4hvDjBg8ibIX6GB4Nu8uwaCCrklexWWHBhZ9Z39TA4c4z",
  render_errors: [view: CrowWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: CrowWeb.PubSub, adapter: Phoenix.PubSub.PG2]

config :crow_data,
  ecto_repos: [CrowData.Repo]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :crow_web, CrowWeb.Endpoint, live_view: [signing_salt: "asdf"]

config :crow_data, Oban,
  repo: CrowData.Repo,
  prune: {:maxlen, 100_000},
  queues: [default: 10, event: 10, command: 1]

config :crow_data, CrowData.Scheduler,
  jobs: [
    {"* * * * *",    {CrowData.Job, :shell, ["backup", "date"]}},
    {"* * * * *",    {CrowData.Job, :shell, ["sleep1", "tst_sleep 10"]}},
    {"* * * * *",    {CrowData.Job, :shell, ["sleep2", "tst_sleep 20"]}},
    {"*/2 * * * *",  {CrowData.Job, :shell, ["test"  , "whoami"]}}
  ]

import_config "#{Mix.env()}.exs"
