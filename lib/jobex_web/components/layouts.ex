defmodule JobexWeb.Layouts do
  @moduledoc """
  Layout components for Jobex.
  """
  use JobexWeb, :html

  embed_templates "layouts/*"

  attr :conn, :any, required: true
  attr :path, :string, required: true
  attr :icon, :string, required: true

  def nav_icon(assigns) do
    current = current_path(assigns.conn)
    is_current = current == assigns.path

    assigns = assign(assigns, :is_current, is_current)
    assigns = assign(assigns, :external, String.contains?(assigns.path, "grafana_host"))

    ~H"""
    <%= if @is_current do %>
      <i class={"fa fa-#{@icon}"}></i>
    <% else %>
      <a
        href={@path}
        class="text-neutral-content hover:text-white"
        target={if @external, do: "_blank"}
      >
        <i class={"fa fa-#{@icon}"}></i>
      </a>
    <% end %>
    """
  end

  attr :flash, :map, required: true

  def flash_messages(assigns) do
    ~H"""
    <div :if={info = Phoenix.Flash.get(@flash, :info)} class="alert alert-info mb-4" role="alert">
      {info}
    </div>
    <div
      :if={error = Phoenix.Flash.get(@flash, :error)}
      class="alert alert-error mb-4"
      role="alert"
    >
      {error}
    </div>
    """
  end

  defp current_path(%Plug.Conn{} = conn) do
    conn.request_path |> String.split("?") |> List.first()
  end

  defp current_path(_), do: ""
end
