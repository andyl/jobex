defmodule JobexData.Ctx.Result do
  use Ecto.Schema
  import Ecto.Changeset

  alias JobexData.Ctx.ObanJob

  schema "results" do
    field :stdout, :string
    field :stderr, :string
    field :status, :integer
    field :attempt, :integer

    belongs_to :oban_job, ObanJob

    timestamps()
  end

  @doc false
  def changeset(ctx, attrs) do
    ctx
    |> cast(attrs, [:status, :attempt, :oban_job_id, :stdout, :stderr])
    |> validate_required([:oban_job_id, :status])
  end
end
