defmodule JobexWeb.Live.Home do
  use JobexWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    uistate = %{
      field: params["field"] || "all",
      value: params["value"] || "na",
      page: to_int(params["page"])
    }

    {:noreply, assign(socket, :uistate, uistate)}
  end

  @impl true
  def render(assigns) do
    rand = :rand.uniform(10000)
    assigns = assign(assigns, :rand, rand)

    ~H"""
    <div class="flex gap-4">
      <div class="w-1/4 border-r border-base-300 pr-4">
        {live_render(@socket, JobexWeb.Live.Home.Sidebar,
          session: %{"uistate" => @uistate},
          id: "yy#{@rand}"
        )}
      </div>
      <div class="w-3/4">
        {live_render(@socket, JobexWeb.Live.Home.Body,
          session: %{"uistate" => @uistate},
          id: "xx#{@rand}"
        )}
      </div>
    </div>
    """
  end

  defp to_int(nil), do: 1
  defp to_int(arg) when is_integer(arg), do: arg
  defp to_int(arg) when is_binary(arg), do: String.to_integer(arg)
end
