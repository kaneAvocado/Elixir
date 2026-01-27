defmodule ProgressTree.Knowledge.TechGene do
  use Ecto.Schema
  import Ecto.Changeset

  @doc_types ~w(чертеж методичка отчет спецификация)
  @statuses ~w(актуально архив устарело)

  schema "tech_genes" do
    field :title, :string
    field :inventory_number, :string
    field :doc_type, :string
    field :description, :string
    field :department, :string
    field :status, :string, default: "актуально"
    field :year, :integer

    belongs_to :author, ProgressTree.Employees.Employee

    timestamps()
  end

  @doc false
  def changeset(tech_gene, attrs) do
    tech_gene
    |> cast(attrs, [
      :title,
      :inventory_number,
      :doc_type,
      :description,
      :author_id,
      :department,
      :status,
      :year
    ])
    |> validate_required([:title, :inventory_number, :doc_type])
    |> validate_inclusion(:doc_type, @doc_types)
    |> validate_inclusion(:status, @statuses)
    |> unique_constraint(:inventory_number)
    |> foreign_key_constraint(:author_id)
  end
end
