defmodule JobexUi.Util do

  # TODO: add 'params' option...
  def live_link(lbl, opts) do
    klas = if opts[:class], do: "class='#{opts[:class]}'", else: ""
    """
    <a href="#{opts[:to]}" to="#{opts[:to]}" data-phx-live-link="push" #{klas}>
    #{lbl}
    </a>
    """
  end
end
