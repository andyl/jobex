defmodule JobexWeb.ErrorHTML do
  @moduledoc """
  Error pages.
  """
  use JobexWeb, :html

  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
