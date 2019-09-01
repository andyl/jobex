defmodule CrowWeb.LayoutView do
  use CrowWeb, :view

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
    if Phoenix.Controller.current_path(conn, %{}) == path do
      lbl
    else
      ~e"""
        <a href="<%= path %>"><%= lbl %></a>
      """
    end
  end
end
