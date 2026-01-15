defmodule ProgressTree.Repo.Migrations.CreateEmployees do
  use Ecto.Migration

  def change do
    create table(:employees) do
      add :full_name, :text, null: false
      add :department, :text
      add :position, :text
      add :hired_at, :date
      add :fired_at, :date

      timestamps()
    end
  end
end
