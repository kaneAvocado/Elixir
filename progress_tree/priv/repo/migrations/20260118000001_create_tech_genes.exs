defmodule ProgressTree.Repo.Migrations.CreateTechGenes do
  use Ecto.Migration

  def change do
    create table(:tech_genes) do
      add :title, :text, null: false
      add :inventory_number, :citext, null: false
      add :doc_type, :string, null: false
      add :description, :text
      add :author_id, references(:employees, on_delete: :nilify_all)
      add :department, :string
      add :status, :string, default: "актуально"
      add :year, :integer

      timestamps()
    end

    create unique_index(:tech_genes, [:inventory_number])
    create index(:tech_genes, [:author_id])
    create index(:tech_genes, [:department])
  end
end
