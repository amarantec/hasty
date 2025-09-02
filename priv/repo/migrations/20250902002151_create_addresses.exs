defmodule Hasty.Repo.Migrations.CreateAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :street, :string
      add :number, :string
      add :city, :string
      add :neighborhood, :string
      add :state, :string
      add :country, :string
      add :zip_code, :string
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:addresses, [:user_id])
  end
end
