defmodule ProgressTree.Employees.Employee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "employees" do
    field :full_name, :string
    field :department, :string
    field :position, :string
    field :hired_at, :date
    field :fired_at, :date

    has_many :tech_genes, ProgressTree.Knowledge.TechGene, foreign_key: :author_id

    timestamps()
  end

  @doc false
  def changeset(employee, attrs) do
    employee
    |> cast(attrs, [:full_name, :department, :position, :hired_at, :fired_at])
    |> validate_required([:full_name])
  end
end
