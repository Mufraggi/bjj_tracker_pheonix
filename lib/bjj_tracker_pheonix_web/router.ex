defmodule BjjTrackerPheonixWeb.Router do
  use BjjTrackerPheonixWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug CORSPlug
  end

  pipeline :auth do
    plug BjjTrackerPheonix.Auth.Pipeline
  end

  scope "/api", BjjTrackerPheonixWeb do
    pipe_through :api

    post "/auth/register", AuthController, :register
    post "/auth/login", AuthController, :login
    post "/auth/refresh", AuthController, :refresh
    post "/auth/logout", AuthController, :logout

  end

  scope "/api", BjjTrackerPheonixWeb do
    pipe_through [:api, :auth]
    resources "/journals", tu , except: [:new, :edit]


    # routes protégées à venir
  end

  if Application.compile_env(:bjj_tracker_pheonix, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: BjjTrackerPheonixWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
