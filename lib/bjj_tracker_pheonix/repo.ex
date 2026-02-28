defmodule BjjTrackerPheonix.Repo do
  use Ecto.Repo,
    otp_app: :bjj_tracker_pheonix,
    adapter: Ecto.Adapters.Postgres
end
