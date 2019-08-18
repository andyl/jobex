defmodule CrowData.Repo do
  use Ecto.Repo,
    otp_app: :crow_data,
    adapter: Ecto.Adapters.Postgres
end
