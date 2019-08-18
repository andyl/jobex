defmodule CrowData.Repo.Migrations.AddResultsTable do
  use Ecto.Migration

  def change do
    create table("results") do
      add :oban_job_id, references("oban_jobs")
      add :stdout, :string
      add :stderr, :string
      add :status, :integer

      add :attempt, :integer

      timestamps()
    end
  end
end
