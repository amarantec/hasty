defmodule Hasty.Repo.Migrations.CreateSchedules do
  use Ecto.Migration

  def change do
    create table(:schedules, primary_key: :false) do
      add :id, :binary_id, primary_key: :true
      add :day_type, :string, null: :false
      add :departure_time, :time, null: :false
      add :line_id, references(:lines, type: :binary_id, on_delete: :nothing)

      timestamps()
    end
    create index(:schedules, [:line_id])
    create index(:schedules, [:day_type])
    create index(:schedules, [:departure_time])
  end
end
