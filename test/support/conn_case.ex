defmodule JobexWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Conn
      import Phoenix.ConnTest

      use Phoenix.VerifiedRoutes,
        endpoint: JobexWeb.Endpoint,
        router: JobexWeb.Router,
        statics: JobexWeb.static_paths()

      @endpoint JobexWeb.Endpoint
    end
  end

  setup _tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
