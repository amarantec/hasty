defmodule Hasty.Addresses.Address do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "addresses" do
    field :street, :string
    field :number, :string
    field :city, :string
    field :neighborhood, :string
    field :state, :string
    field :country, :string
    field :zip_code, :string
    belongs_to :user, Hasty.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @digits_regex ~r/^\d+$/

  @doc false
  def changeset(address, attrs, user_scope) do
    address
    |> cast(attrs, [:street, :number, :city, :neighborhood, :state, :country, :zip_code])
    |> validate_required([:street, :number, :city, :neighborhood, :state, :country, :zip_code])
    # only numbers
    |> validate_format(:number, @digits_regex, message: "Must contain only digits")
    |> validate_format(:zip_code, @digits_regex, message: "Must contain only digits")
    #length
    |> validate_length(:number, min: 1)
    |> validate_length(:zip_code, is: 8, message: "Must contain 8 digits")
    |> validate_length(:state, is: 2, message: "Must contain 2 characters. Ex: SP")
    |> put_change(:user_id, user_scope.user.id)
  end
end
