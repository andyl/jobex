defmodule CrowData.Query do

  alias CrowData.Repo
  alias CrowData.Ctx.ObanJob
  import Ecto.Query

  def all_jobs do
    from(j in ObanJob, preload: [:results]) 
    |> Repo.all()
  end

  def jobs_for(_type) do
  end
end
