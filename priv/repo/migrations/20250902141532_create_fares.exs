defmodule Hasty.Repo.Migrations.CreateFares do
  use Ecto.Migration

  def change do
    create table(:fares, primary_key: :false) do
      add :id, :binary_id, primary_key: :true
      add :price, :decimal, null: :false
      add :line_id, references(:lines, type: :binary_id, on_delete: :nothing)
      add :origin_stop_id, references(:bus_stops, type: :binary_id, on_delete: :nothing)
      add :destination_stop_id, references(:bus_stops, type: :binary_id, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end
    create index(:fares, [:line_id])
    create index(:fares, [:origin_stop_id])
    create index(:fares, [:destination_stop_id])
  end
end
