defmodule Caniuse.Repo.Migrations.CreateResource do
  use Ecto.Migration

  def change do
    create table(:resource) do
      add :name, :string
      add :description, :string
      add :is_locked, :boolean, default: false
      add :last_change, :datetime
      add :changed_by, :string

      timestamps
    end
    create unique_index(:resource, [:name])

  end
end
