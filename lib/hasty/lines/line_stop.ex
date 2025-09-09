defmodule Hasty.Lines.LineStop do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: :true}
  @foreign_key_type :binary_id
  schema "line_stops" do
    field :order, :integer
    belongs_to :line, Hasty.Lines.Line
    belongs_to :bus_stop, Hasty.Buses.BusStop

    timestamps()
  end
  def changeset(line_stop, attrs) do
    line_stop
    |> cast(attrs, [:order, :line_id, :bus_stop_id])
    |> validate_required([:order, :line_id, :bus_stop_id])
  end
end
