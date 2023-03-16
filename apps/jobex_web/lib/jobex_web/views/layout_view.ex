defmodule JobexWeb.LayoutView do
  use JobexWeb, :view

  def hdr_link(conn, lbl, path) do
    ~e"""
    <li class="nav-item">
      <%= active_link(conn, lbl, to: path, class_active: "nav-link active", class_inactive: "nav-link") %>
    </li>
    """
  end

  def ftr_link(conn, lbl, path) do
    ~e"""
    <li class="nav-item">
      <%= active_link(conn, lbl, to: path, class_active: "nav-link disabled", class_inactive: "nav-link") %>
    </li>
    """
  end

  def link_to_unless_current(conn, lbl, path) do
    if is_current(conn, path) do
      lbl
    else
      ~e"""
        <a href="<%= path %>"><%= lbl %></a>
      """
    end
  end

  def hdr_icon(conn, lbl) do
    {path, icon_type} =
      case lbl do
        "home"   -> {"/home",     "home"}
        "help"   -> {"/help",     "question-circle"}
        "admin"  -> {"/admin",    "cog"}
        "cal"    -> {"/schedule", "calendar"}
        "chart"  -> {"http://grafana_host:3030/d/Pc0ZYbKWk/cron", "chart-line"}
      end
    icon_html = "<i class='fa fa-#{icon_type}'></i>"

    if is_current(conn, path) do
      icon_html
    else
      tgt = if String.contains?(path, "grafana_host"), do: "target='_blank'", else: ""
      "<a href='#{path}' #{tgt}>#{icon_html}</a>"
    end
  end

  def footer_img(conn) do
    hostid = "7edf99"
    r_path = conn.request_path
    """
    <img src="https://badger.casmacc.net/png0/#{hostid}?path=#{r_path}"></img>
    """ |> Phoenix.HTML.raw()
  end

  defp is_current(conn, path) do
    [current | _] = Phoenix.Controller.current_path(conn) |> String.split("?")
    current == path
  end
end
