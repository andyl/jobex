defmodule JobexCore.Sch.ObanJob do
  use Ecto.Schema

  alias JobexCore.Sch.Result

  schema "oban_jobs" do
    field :state, :string
    field :queue, :string
    field :worker, :string

    field :args, :map
    field :errors, {:array, :map}

    field :attempt, :integer
    field :max_attempts, :integer

    field :inserted_at,  :utc_datetime
    field :scheduled_at, :utc_datetime
    field :attempted_at, :utc_datetime
    field :completed_at, :utc_datetime

    has_many :results, Result
  end
end
