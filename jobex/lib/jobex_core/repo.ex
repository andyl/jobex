defmodule JobexCore.Repo do
  use Ecto.Repo,
    otp_app: :jobex_core,
    adapter: Ecto.Adapters.Postgres
end
