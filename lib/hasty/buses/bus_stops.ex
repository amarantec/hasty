defmodule Hasty.Buses.BusStops do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: :true}
  @foreign_key_type :binary_id
  schema "bus_stops" do
    field :name, :string
    field :latitude, :float
    field :longitude, :float
  timestamps(type: :utc_datetime)
  end
  
  def changeset(bus_stop, attrs) do
    bus_stop
    |> cast(attrs, [:name, :latitude, :longitude])
    |> validate_required([:name, :latitude, :longitude])
  end
end
