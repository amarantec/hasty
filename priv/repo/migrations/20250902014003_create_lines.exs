defmodule Hasty.Repo.Migrations.CreateLines do
  use Ecto.Migration

  def change do
    create table(:lines, primary_key: :false) do
      add :id, :binary_id, primary_key: :true
      add :name, :string, null: :false
      add :flat_fare, :boolean, default: :true
      add :base_price, :decimal, null: :false

      timestamps(type: :utc_datetime)
    end
    create index(:lines, [:name], unique: :true)
  end
end
