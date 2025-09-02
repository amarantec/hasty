defmodule Hasty.Lines.Fare do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: :true}
  @foreign_key_type :binary_id
  schema "fares" do
    field :price, :decimal
    belongs_to :line_id, Hasty.Lines.Line
    belongs_to :origin_stop_id, Hasty.Buses.BusStops
    belongs_to :destination_stop_id, Hasty.Buses.BusStops

    timestamps(type: :utc_datetime)
  end
  
  def changeset(fare, attrs) do
    fare
    |> cast(attrs, [:price, :line_id, :origin_stop_id, :destination_stop_id])
    |> validate_required([:price, :line_id, :origin_stop_id, :destination_stop_id])
  end
end
