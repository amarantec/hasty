defmodule Hasty.Repo.Migrations.CreateBusStops do
  use Ecto.Migration

  def change do
    create table(:bus_stops, primary_key: :false) do
      add :id, :binary_id, primary_key: :true
      add :name, :string, null: :false
      add :latitude, :float, null: :false
      add :longitude, :float, null: :false

      timestamps()
    end
    create index(:bus_stops, [:name], unique: :true)
  end
end
