defmodule JobexWeb.Router do
  use JobexWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    # plug Phoenix.LiveView.Flash
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", JobexWeb do
    pipe_through :browser

    get "/",         HomeController, :index
    get "/jobs/:id", HomeController, :jobs
    get "/schedule", HomeController, :schedule
    get "/admin",    HomeController, :admin
    get "/help",     HomeController, :help

    live "/home", Live.Home
    live "/demo", Live.Demo
  end

  scope "/api", JobexWeb do
    pipe_through :api
  end
end
