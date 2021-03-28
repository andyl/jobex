ExUnit.start()
Application.ensure_all_started(:ecto)
Ecto.Adapters.SQL.Sandbox.mode(JobexCore.Repo, :manual)
