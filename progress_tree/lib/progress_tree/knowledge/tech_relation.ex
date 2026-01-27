defmodule ProgressTree.Knowledge.TechRelation do
  use Ecto.Schema
  import Ecto.Changeset

  @relation_types ~w(наследование вдохновение сборка форк)

  schema "tech_relations" do
    field :relation_type, :string
    field :notes, :string

    belongs_to :parent, ProgressTree.Knowledge.TechGene
    belongs_to :child, ProgressTree.Knowledge.TechGene

    timestamps()
  end

  @doc false
  def changeset(tech_relation, attrs) do
    tech_relation
    |> cast(attrs, [:parent_id, :child_id, :relation_type, :notes])
    |> validate_required([:parent_id, :child_id, :relation_type])
    |> validate_inclusion(:relation_type, @relation_types)
    |> unique_constraint([:parent_id, :child_id, :relation_type])
    |> foreign_key_constraint(:parent_id)
    |> foreign_key_constraint(:child_id)
  end

  def relation_types, do: @relation_types
end
