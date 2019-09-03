defmodule CrowWeb.Live.Demo do
  use Phoenix.LiveView
  use Timex
  alias CrowWeb.DemoView

  def render(assigns) do
    DemoView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    :timer.send_interval(10000, self(), :tick)
    {:ok, assign(socket, count: 0, valid_url: false, update_str: "", date: ldate())}
  end

  # ----- clock

  def handle_info(:tick, socket) do
    {:noreply, update(socket, :date, fn _ -> ldate() end)}
  end

  # ----- counter 

  def handle_event("inc", _, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  def handle_event("dec", _, socket) do
    {:noreply, update(socket, :count, &(&1 - 1))}
  end

  # ----- text input
  
  def handle_event("update_string", arg, socket) do
    slen = String.length(arg["str"])
    ustr = if slen > 0, do: "length #{slen}", else: ""
    ufun = fn _ -> ustr end
    {:noreply, update(socket, :update_str, ufun)}
  end

  # ----- url validation

  def handle_event("validate_url", arg, socket) do
    {_, boolean_result, _} = validate_url(arg["url"])
    vfun = fn _ -> boolean_result end
    {:noreply, update(socket, :valid_url, vfun)}
  end

  # ----- misc

  defp ldate do
    Timex.now("US/Pacific")
    |> Timex.format!("%d %b %H:%M", :strftime)
  end

  defp validate_url(str) do
    uri = URI.parse(str)

    case uri do
      %URI{scheme: nil} -> {:error, false, uri}
      %URI{host: nil}   -> {:error, false, uri}
      %URI{path: nil}   -> {:error, false, uri}
      uri -> {:ok, true, uri}
    end
  end
end
