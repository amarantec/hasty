defmodule Hasty.Lines.Line do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: :true}
  @foreign_key_type :binary_id
  schema "lines" do
    field :name, :string
    field :flat_fare, :boolean
    field :base_price, :decimal

    has_many :buses, Hasty.Buses.Bus

    timestamps(type: :utc_datetime)
  end
  @doc false
  def changeset(line, attrs) do
    line
    |> cast(attrs, [:name, :flat_fare, :base_price])
    |> validate_required([:name, :flat_fare, :base_price])
  end
end
