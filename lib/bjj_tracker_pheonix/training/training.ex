defmodule BjjTrackerPheonix.Training do
  import Ecto.Query
  alias BjjTrackerPheonix.Repo
  alias BjjTrackerPheonix.Training.TrainingJournal

  def list_journals(user_id) do
    from(j in TrainingJournal,
      where: j.user_id == ^user_id,
      order_by: [desc: j.date]
    )
    |> Repo.all()
  end

  def get_journal(id, user_id) do
    Repo.get_by(TrainingJournal, id: id, user_id: user_id)
  end

  def create_journal(user_id, attrs) do
    %TrainingJournal{}
    |> TrainingJournal.changeset(Map.put(attrs, "user_id", user_id))
    |> Repo.insert()
  end

  def update_journal(id, user_id, attrs) do
    case get_journal(id, user_id) do
      nil -> {:error, :not_found}
      journal ->
        journal
        |> TrainingJournal.changeset(attrs)
        |> Repo.update()
    end
  end

  def delete_journal(id, user_id) do
    case get_journal(id, user_id) do
      nil -> {:error, :not_found}
      journal -> Repo.delete(journal)
    end
  end
end