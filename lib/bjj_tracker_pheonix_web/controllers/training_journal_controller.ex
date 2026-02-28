defmodule BjjTrackerPheonixWeb.TrainingJournalController do
  use BjjTrackerPheonixWeb, :controller

  alias BjjTrackerPheonix.Training
  alias BjjTrackerPheonix.Auth.Guardian

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    journals = Training.list_journals(user.id)

    conn
    |> json(%{data: Enum.map(journals, &format_journal/1)})
  end

  def show(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    case Training.get_journal(id, user.id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Séance introuvable"})
      journal ->
        conn
        |> json(%{data: format_journal(journal)})
    end
  end

  def create(conn, params) do
    user = Guardian.Plug.current_resource(conn)

    case Training.create_journal(user.id, params) do
      {:ok, journal} ->
        conn
        |> put_status(:created)
        |> json(%{data: format_journal(journal)})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    user = Guardian.Plug.current_resource(conn)

    case Training.update_journal(id, user.id, params) do
      {:ok, journal} ->
        conn
        |> json(%{data: format_journal(journal)})
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Séance introuvable"})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    case Training.delete_journal(id, user.id) do
      {:ok, _} ->
        conn
        |> json(%{message: "Séance supprimée"})
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Séance introuvable"})
    end
  end

  defp format_journal(journal) do
    %{
      id: journal.id,
      date: journal.date,
      session_type: journal.session_type,
      duration: journal.duration,
      energy: journal.energy,
      mental: journal.mental,
      sleep: journal.sleep,
      pain_level: journal.pain_level,
      pain_zone: journal.pain_zone,
      positions: journal.positions,
      technique_types: journal.technique_types,
      technique_free_text: journal.technique_free_text,
      what_worked: journal.what_worked,
      what_didnt_work: journal.what_didnt_work,
      sparring: journal.sparring,
      fatigue: journal.fatigue,
      mood: journal.mood,
      notes: journal.notes,
      inserted_at: journal.inserted_at,
      updated_at: journal.updated_at
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