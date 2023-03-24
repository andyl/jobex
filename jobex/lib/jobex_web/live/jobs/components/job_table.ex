defmodule JobexWeb.Jobs.Components.JobTable do
  use Phoenix.Component

  attr :job_state, :string, required: true
  slot :inner_block, required: true

  def tr(assigns) do
    ~H"""
    <tr class={bg_klas(@job_state)}>
      <%= render_slot(@inner_block) %>
    </tr>
    """
  end

  slot :inner_block

  def td(assigns) do
    ~H"""
    <td class="border border-slate-500 px-1">
      <%= render_slot(@inner_block) %>
    </td>
    """
  end

  # ----- helpers

  defp bg_klas(job_state) do
    case job_state do
      "available" -> "bg-yellow-200"
      "executing" -> "bg-green-300"
      "retryable" -> "bg-orange-300"
      "discarded" -> "bg-red-300"
      _ -> nil
    end
  end
end
