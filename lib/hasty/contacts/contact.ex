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

  @doc false
  def changeset(contact, attrs, user_scope) do
    contact
    |> cast(attrs, [:ddi, :ddd, :phone_number])
    |> validate_required([:ddi, :ddd, :phone_number])
    |> put_change(:user_id, user_scope.user.id)
  end
end
