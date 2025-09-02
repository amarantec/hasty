defmodule Hasty.Contacts.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contacts" do
    field :ddi, :string
    field :ddd, :string
    field :phone_number, :string
    field :user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @digits_regex ~r/^\d+$/
  @doc false
  def changeset(contact, attrs, user_scope) do
    contact
    |> cast(attrs, [:ddi, :ddd, :phone_number])
    |> validate_required([:ddi, :ddd, :phone_number])
    # only digits
    |> validate_format(:ddi, @digits_regex, message: "Must contain only digits")
    |> validate_format(:ddd, @digits_regex, message: "Must contain only digits")
    |> validate_format(:phone_number, @digits_regex, message: "Must contain only digits")
    # length
    |> validate_length(:ddi, min: 1, max: 3)
    |> validate_length(:ddd, is: 2)
    |> validate_length(:phone_number, min: 8, max: 9)
    |> put_change(:user_id, user_scope.user.id)
  end
end
