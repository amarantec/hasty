defmodule Hasty.Lines.Schedule do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: :true}
  @foreign_key_type :binary_id
  schema "schedules" do
    field :day_type, :string
    field :departure_time, :time
    belongs_to :line_id, Hasty.Lines.Line

    timestamps(type: :utc_datetime)
  end

  def changeset(schedule, attrs) do
    schedule
    |> cast(attrs, [:day_type, :departure_time])
    |> validate_required([:day_type, :departure_time])
  end
end
