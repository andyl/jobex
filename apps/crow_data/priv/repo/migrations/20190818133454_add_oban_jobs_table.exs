defmodule CrowData.Repo.Migrations.AddObanJobsTable do
  use Ecto.Migration

  defdelegate up,   to: Oban.Migrations
  defdelegate down, to: Oban.Migrations

  def change do
    create table("results") do
      add :oban_job_id, references("oban_jobs"), on_delete: :delete_all
      add :stdout, :string
      add :stderr, :string
      add :status, :integer

      timestamps()
    end
  end
end
