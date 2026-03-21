defmodule ProgressTreeWeb.Router do
  use ProgressTreeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ProgressTreeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ProgressTreeWeb do
    pipe_through :browser

    live "/", GenealogyLive.Index, :index
    live "/genealogy/:id", GenealogyLive.Show, :show
  end

  if Application.compile_env(:progress_tree, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ProgressTreeWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
