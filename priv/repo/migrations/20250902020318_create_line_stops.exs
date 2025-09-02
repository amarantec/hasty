defmodule Hasty.Repo.Migrations.CreateLineStops do
  use Ecto.Migration

  def change do
    create table(:line_stops, primary_key: :false) do
      add :id, :binary_id, primary_key: :true
      add :order, :integer, null: :false
      add :line_id, references(:lines, type: :binary_id, on_delete: :nothing)
      add :bus_stop_id, references(:bus_stops, type: :binary_id, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end
  end
end
