defmodule BjjTrackerPheonix.Training.TrainingJournal do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @valid_session_types ~w(technique drilling sparring competition open_mat mixte)
  @valid_pain_levels ~w(none legere_gene blessure)

  schema "training_journals" do
    field :date, :date
    field :session_type, :string
    field :duration, :integer
    field :energy, :integer
    field :mental, :integer
    field :sleep, :integer
    field :pain_level, :string
    field :pain_zone, :string
    field :positions, {:array, :string}, default: []
    field :technique_types, {:array, :string}, default: []
    field :technique_free_text, :string
    field :what_worked, :string
    field :what_didnt_work, :string
    field :sparring, :map
    field :fatigue, :integer
    field :mood, :integer
    field :notes, :string

    belongs_to :user, BjjTrackerPheonix.Accounts.User

    timestamps()
  end

  def changeset(journal, attrs) do
    journal
    |> cast(attrs, [
      :date, :session_type, :duration, :energy, :mental, :sleep,
      :pain_level, :pain_zone, :positions, :technique_types,
      :technique_free_text, :what_worked, :what_didnt_work,
      :sparring, :fatigue, :mood, :notes
    ])
    |> validate_required([:date, :session_type, :duration])
    |> validate_inclusion(:session_type, @valid_session_types)
    |> validate_inclusion(:pain_level, @valid_pain_levels)
    |> validate_number(:duration, greater_than: 0)
    |> validate_number(:energy, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> validate_number(:mental, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> validate_number(:sleep, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> validate_number(:fatigue, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> validate_number(:mood, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
  end
end