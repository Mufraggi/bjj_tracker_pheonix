defmodule BjjTrackerPheonix.Accounts.RefreshToken do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "refresh_tokens" do
    field :token, :string
    field :expires_at, :utc_datetime
    field :revoked_at, :utc_datetime

    belongs_to :user, BjjTrackerPheonix.Accounts.User

    timestamps()
  end

  def changeset(refresh_token, attrs) do
    refresh_token
    |> cast(attrs, [:token, :expires_at])
    |> put_change(:user_id, attrs[:user_id])
    |> validate_required([:token, :expires_at, :user_id])
    |> unique_constraint(:token)
  end
end
