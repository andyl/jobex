defmodule JobexCore.Repo do
  use Ecto.Repo,
    otp_app: :jobex,
    adapter: Ecto.Adapters.Postgres
end
