defmodule BjjTrackerPheonix.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @valid_roles ~w(practitioner coach owner)
  @valid_belts ~w(white blue purple brown black)

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :first_name, :string
    field :last_name, :string
    field :role, :string, default: "practitioner"
    field :belt, :string, default: "white"
    field :stripes, :integer, default: 0
    field :age, :integer

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :first_name, :last_name, :role, :belt, :stripes, :age])
    |> update_change(:email, &String.downcase/1)
    |> validate_required([:email, :password, :first_name, :last_name])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> validate_length(:password, min: 8)
    |> validate_inclusion(:role, @valid_roles)
    |> validate_inclusion(:belt, @valid_belts)
    |> validate_number(:stripes, greater_than_or_equal_to: 0, less_than_or_equal_to: 4)
    |> validate_number(:age, greater_than: 0, less_than: 120)
    |> unique_constraint(:email)
    |> hash_password()
  end

  defp hash_password(%{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
  end
  defp hash_password(changeset), do: changeset
end
