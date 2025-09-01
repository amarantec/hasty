defmodule Hasty.Repo.Migrations.UserProfile do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :first_name, :string 
      add :last_name, :string 
      add :bio, :text
    end
  end
end
