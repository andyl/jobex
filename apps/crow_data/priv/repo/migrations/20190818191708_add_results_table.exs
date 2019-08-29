defmodule CrowData.Repo.Migrations.AddResultsTable do
  use Ecto.Migration

  def change do
    create table("results") do
      add :oban_job_id, references("oban_jobs", on_delete: :delete_all)
      add :stdout, :text
      add :stderr, :text
      add :status, :integer

      add :attempt, :integer

      timestamps()
    end
  end
end
