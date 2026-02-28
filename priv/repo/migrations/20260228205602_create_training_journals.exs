defmodule BjjTrackerPheonix.Repo.Migrations.CreateTrainingJournals do
  use Ecto.Migration

  def change do
    create table(:training_journals, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :date, :date, null: false
      add :session_type, :string, null: false
      add :duration, :integer, null: false
      add :energy, :integer
      add :mental, :integer
      add :sleep, :integer
      add :pain_level, :string
      add :pain_zone, :string
      add :positions, {:array, :string}, default: []
      add :technique_types, {:array, :string}, default: []
      add :technique_free_text, :text
      add :what_worked, :text
      add :what_didnt_work, :text
      add :sparring, :map
      add :fatigue, :integer
      add :mood, :integer
      add :notes, :text

      timestamps()
    end

    create index(:training_journals, [:user_id])
    create index(:training_journals, [:date])
  end
end