defmodule JobexWeb.Live.Home do
  use Phoenix.LiveView

  def mount(_session, socket) do
    JobexWeb.Endpoint.subscribe("arrow-key")
    :timer.apply_interval(1000, JobexWeb.Endpoint, :broadcast_from, [self(), "time-tick", "home", %{}])
    {:ok, socket}
  end

  def render(assigns) do
    rand = :rand.uniform(10000)
    ~L"""
    <div class="row">
      <div class="col-md-3" style='border-right: 1px solid lightgray;'>
        HELLO WORLD THIS IS HOME <%= rand %>
        <%# live_render(@socket, JobexWeb.Live.Home.Sidebar, session: %{uistate: @uistate}, id: "yy#{rand}") %>
      </div>
      <div class="col-md-9">
        <%# live_render(@socket, JobexWeb.Live.Home.Body, session: %{uistate: @uistate}, id: "xx#{rand}") %>
      </div>
    </div>
    """
  end

  # ----- params handlers -----

  def handle_params(params, _url, socket) do

    uistate = %{
      field: params["field"] || "all",
      value: params["value"] || "na",
      page:  params["page"] |> to_int()
    }

    {:noreply, assign(socket, %{uistate: uistate})}
  end

  # ----- pub/sub handlers -----

  def handle_info(%{topic: "arrow-key", payload: payload}, socket) do
    {:noreply, Phoenix.LiveView.live_redirect(socket, to: payload.newpath, replace: true)}
  end

  # ----- helpers -----

  defp to_int(nil), do: 1
  defp to_int(arg) when is_integer(arg), do: arg
  defp to_int(arg) when is_binary(arg), do: String.to_integer(arg)

end
