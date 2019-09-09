defmodule CrowData.Repo.Migrations.AddObanJobsTable do
  use Ecto.Migration

  def up do
    Oban.Migrations.up(version: 4)
  end

  def down do
    Oban.Migrations.up(version: 4)
  end
end
