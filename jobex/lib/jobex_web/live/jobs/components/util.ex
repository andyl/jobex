defmodule JobexWeb.Jobs.Components.Util do
  use Phoenix.Component
  use Timex

  attr :tick, :integer, required: true
  attr :class, :string, default: nil

  def clock(assigns) do
    ~H"""
    <div class={@class}>
      <%= current_date_string(@tick) %>
    </div>
    """
  end

  # ----- helpers

  defp current_date_string(_tick) do
    Timex.now("US/Pacific")
    |> Timex.format!("%Y-%b-%d %H:%M:%S", :strftime)
  end
end
