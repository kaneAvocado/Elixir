defmodule ProgressTree.Knowledge do
  @moduledoc """
  Context for technical genes and relations in NII Progress knowledge base.
  """

  import Ecto.Query, warn: false
  alias ProgressTree.Repo
  alias ProgressTree.Knowledge.{TechGene, TechRelation}

  def list_genes do
    TechGene
    |> order_by([g], desc: g.year, asc: g.title)
    |> Repo.all()
  end

  def get_gene!(id), do: Repo.get!(TechGene, id)

  def get_gene_with_author!(id) do
    TechGene
    |> preload(:author)
    |> Repo.get!(id)
  end

  def create_gene(attrs \\ %{}) do
    %TechGene{}
    |> TechGene.changeset(attrs)
    |> Repo.insert()
  end

  def update_gene(%TechGene{} = gene, attrs) do
    gene
    |> TechGene.changeset(attrs)
    |> Repo.update()
  end

  def delete_gene(%TechGene{} = gene) do
    Repo.delete(gene)
  end

  def change_gene(%TechGene{} = gene, attrs \\ %{}) do
    TechGene.changeset(gene, attrs)
  end

  def create_relation(attrs \\ %{}) do
    %TechRelation{}
    |> TechRelation.changeset(attrs)
    |> Repo.insert()
  end

  def list_relations_for_gene(gene_id) do
    from(r in TechRelation,
      where: r.parent_id == ^gene_id or r.child_id == ^gene_id,
      preload: [:parent, :child]
    )
    |> Repo.all()
  end
end
