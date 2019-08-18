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
  queues: [default: 10, events: 5, jobs: 50]

config :crow_data, CrowData.Scheduler,
  jobs: [
    # Every minute
    {"* * * * *",    {CrowData.Job, :shell, ["backup", "date"]}},
    {"*/2 * * * *",  {CrowData.Job, :shell, ["test"  , "whoami"]}},
    # {"* * * * *",  fn -> %{asdf: "qwer"} |> CrowData.Worker.Shell.new() |> Oban.insert() end}
    # Every 15 minutes
    # {"*/15 * * * *",   fn -> System.cmd("rm", ["/tmp/tmp_"]) end},
    # Runs on 18, 20, 22, 0, 2, 4, 6:
    # {"0 18-6/2 * * *", fn -> :mnesia.backup('/var/backup/mnesia') end},
    # Runs every midnight:
    # {"@daily",         {Backup, :backup, []}}
  ]

import_config "#{Mix.env()}.exs"
