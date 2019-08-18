defmodule CrowData.Ctx.Result do
  use Ecto.Schema
  import Ecto.Changeset

  alias CrowData.Ctx.ObanJob

  schema "results" do
    field :stdout, :string
    field :stderr, :string
    field :status, :integer

    belongs_to :oban_job, ObanJob

    timestamps()
  end

  @doc false
  def changeset(ctx, attrs) do
    ctx
    |> cast(attrs, [:title, :views, :status, :oban_job_id])
    |> validate_required([:oban_job_id, :status])
  end
end
