defmodule BjjTrackerPheonix.Accounts do
  import Ecto.Query
  alias BjjTrackerPheonix.Repo
  alias BjjTrackerPheonix.Accounts.{User, RefreshToken}

  def register_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def get_user(id), do: Repo.get(User, id)

  def get_user_by_email(email) do
    Repo.get_by(User, email: String.downcase(email))
  end

  def authenticate_user(email, password) do
    user = get_user_by_email(email)

    cond do
      user && Bcrypt.verify_pass(password, user.password_hash) ->
        {:ok, user}
      user ->
        {:error, :invalid_password}
      true ->
        Bcrypt.no_user_verify()
        {:error, :not_found}
    end
  end

  # Refresh tokens

  def create_refresh_token(user_id, token, expires_at) do
    %RefreshToken{}
    |> RefreshToken.changeset(%{
      user_id: user_id,
      token: token,
      expires_at: expires_at
    })
    |> Repo.insert()
  end

  def get_refresh_token(token) do
    Repo.get_by(RefreshToken, token: token)
  end

  def revoke_refresh_token(token) do
    case get_refresh_token(token) do
      nil -> {:error, :not_found}
      refresh_token ->
        refresh_token
        |> Ecto.Changeset.change(revoked_at: DateTime.utc_now() |> DateTime.truncate(:second))
        |> Repo.update()
    end
  end

  def revoke_all_user_tokens(user_id) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    from(t in RefreshToken,
      where: t.user_id == ^user_id and is_nil(t.revoked_at)
    )
    |> Repo.update_all(set: [revoked_at: now])
  end

  def validate_refresh_token(token) do
    now = DateTime.utc_now()

    case get_refresh_token(token) do
      nil -> {:error, :not_found}
      %{revoked_at: revoked_at} when not is_nil(revoked_at) -> {:error, :revoked}
      t ->
        if DateTime.compare(t.expires_at, now) == :gt,
          do: {:ok, t},
          else: {:error, :expired}
    end
  end
end
