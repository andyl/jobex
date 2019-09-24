defmodule JobexData.Repo do
  use Ecto.Repo,
    otp_app: :jobex_data,
    adapter: Ecto.Adapters.Postgres
end
