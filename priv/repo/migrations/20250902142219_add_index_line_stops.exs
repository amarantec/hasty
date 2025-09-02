defmodule Hasty.Repo.Migrations.AddIndexLineStops do
  use Ecto.Migration

  def change do
    create index(:line_stops, [:line_id])  
    create index(:line_stops, [:bus_stop_id])  
  end
end
