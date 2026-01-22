defmodule ProgressTree.Repo.Migrations.CreateTechRelations do
  use Ecto.Migration

  def change do
    create table(:tech_relations) do
      add :parent_id, references(:tech_genes, on_delete: :delete_all), null: false
      add :child_id, references(:tech_genes, on_delete: :delete_all), null: false
      add :relation_type, :string, null: false
      add :notes, :text

      timestamps()
    end

    create unique_index(:tech_relations, [:parent_id, :child_id, :relation_type])
    create index(:tech_relations, [:child_id])
    create index(:tech_relations, [:parent_id])
  end
end
