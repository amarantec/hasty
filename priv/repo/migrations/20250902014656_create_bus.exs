defmodule Hasty.Repo.Migrations.CreateBus do
  use Ecto.Migration

  def change do
    create table(:buses, primary_key: :false) do
      add :id, :binary_id, primary_key: :true
      add :plate, :string, null: :false
      add :capacity, :integer, null: :false
      add :line_id, references(:lines, type: :binary_id, on_delete: :nothing)

      timestamps()
    end
    create index(:buses, [:plate], unique: :true)
  end
end
