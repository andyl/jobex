defmodule Joba.Repo do
  use Ecto.Repo,
    otp_app: :joba,
    adapter: Ecto.Adapters.Postgres
end
