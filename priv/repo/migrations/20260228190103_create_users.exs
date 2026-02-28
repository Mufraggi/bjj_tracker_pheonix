defmodule BjjTrackerPheonix.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :role, :string, null: false, default: "practitioner"
      add :belt, :string, default: "white"
      add :stripes, :integer, default: 0
      add :age, :integer

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
