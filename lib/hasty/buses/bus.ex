defmodule Hasty.Buses.Bus do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: :true}
  @foreign_key_type :binary_id
  schema "buses" do
    field :plate, :string
    field :capacity, :integer
    belongs_to :line_id, Hasty.Lines.Line

    timestamps(type: :utc_datetime)
  end

  @bus_plate_regex ~r/^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$/

  def changeset(bus, attrs) do
    bus
    |> cast(attrs, [:plate, :capacity])
    |> validate_required([:plate, :capacity])
    |> validate_format(:plate, @bus_plate_regex)
  end
end
