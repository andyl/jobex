defmodule JobexCore.Repo.Migrations.AddObanJobsTable do
  use Ecto.Migration

  def up do
    Oban.Migrations.up(version: 7)
  end

  def down do
    Oban.Migrations.up(version: 7)
  end
end
