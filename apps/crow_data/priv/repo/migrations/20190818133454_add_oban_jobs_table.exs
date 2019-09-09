defmodule CrowData.Repo.Migrations.AddObanJobsTable do
  use Ecto.Migration

  defdelegate up,   to: Oban.Migrations(version: 4)
  defdelegate down, to: Oban.Migrations(version: 4)

  def change do
  end
end
