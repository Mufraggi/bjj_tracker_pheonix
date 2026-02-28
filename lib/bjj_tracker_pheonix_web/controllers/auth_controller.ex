defmodule BjjTrackerPheonixWeb.AuthController do
  use BjjTrackerPheonixWeb, :controller

  alias BjjTrackerPheonix.Accounts
  alias BjjTrackerPheonix.Auth.Guardian

  def register(conn, params) do
    case Accounts.register_user(params) do
      {:ok, user} ->
        {:ok, access_token, _claims} = Guardian.encode_and_sign(user, %{}, ttl: {15, :minute})
        {:ok, refresh_token} = generate_refresh_token(user)

        conn
        |> put_status(:created)
        |> json(%{
          access_token: access_token,
          refresh_token: refresh_token,
          user: format_user(user)
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, access_token, _claims} = Guardian.encode_and_sign(user, %{}, ttl: {15, :minute})
        {:ok, refresh_token} = generate_refresh_token(user)

        conn
        |> json(%{
          access_token: access_token,
          refresh_token: refresh_token,
          user: format_user(user)
        })

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Email ou mot de passe incorrect"})
    end
  end

  def refresh(conn, %{"refresh_token" => refresh_token}) do
    case Accounts.validate_refresh_token(refresh_token) do
      {:ok, token_record} ->
        user = Accounts.get_user(token_record.user_id)

        Accounts.revoke_refresh_token(refresh_token)
        {:ok, new_refresh_token} = generate_refresh_token(user)
        {:ok, access_token, _claims} = Guardian.encode_and_sign(user, %{}, ttl: {15, :minute})

        conn
        |> json(%{
          access_token: access_token,
          refresh_token: new_refresh_token
        })

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Refresh token invalide ou expiré"})
    end
  end

  def logout(conn, %{"refresh_token" => refresh_token}) do
    Accounts.revoke_refresh_token(refresh_token)

    conn
    |> json(%{message: "Déconnecté"})
  end

  # Private

  defp generate_refresh_token(user) do
    token = :crypto.strong_rand_bytes(64) |> Base.url_encode64(padding: false)
    expires_at = DateTime.utc_now() |> DateTime.add(30, :day) |> DateTime.truncate(:second)

    case Accounts.create_refresh_token(user.id, token, expires_at) do
      {:ok, _} -> {:ok, token}
      error -> error
    end
  end

  defp format_user(user) do
    %{
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      role: user.role,
      belt: user.belt,
      stripes: user.stripes
    }
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
