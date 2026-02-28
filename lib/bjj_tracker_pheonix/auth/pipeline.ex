defmodule BjjTrackerPheonix.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :bjj_tracker_pheonix,
    module: BjjTrackerPheonix.Auth.Guardian,
    error_handler: BjjTrackerPheonix.Auth.ErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
