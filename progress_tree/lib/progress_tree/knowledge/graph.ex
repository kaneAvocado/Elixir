defmodule ProgressTree.Knowledge.Graph do
  @moduledoc "Builds nodes/edges JSON for D3 force graph."

  alias ProgressTree.Knowledge
  alias ProgressTree.Repo
  alias ProgressTree.Knowledge.TechRelation
  import Ecto.Query

  def build_graph_json(root_gene, descendants) do
    descendant_ids = Enum.map(descendants, & &1.child_id)
    node_ids = MapSet.new([root_gene.id | descendant_ids])

    nodes =
      ([root_gene] ++ genes_for_ids(descendant_ids))
      |> Enum.uniq_by(& &1.id)
      |> Enum.map(&gene_node/1)

    edges = edges_for_nodes(node_ids)

    %{nodes: nodes, edges: edges}
  end

  defp genes_for_ids([]), do: []

  defp genes_for_ids(id_list) do
    Knowledge.TechGene
    |> where([g], g.id in ^id_list)
    |> Repo.all()
  end

  defp gene_node(gene) do
    %{
      id: gene.id,
      label: gene.title,
      inventory_number: gene.inventory_number,
      department: gene.department,
      doc_type: gene.doc_type,
      status: gene.status,
      year: gene.year
    }
  end

  defp edges_for_nodes(node_ids) do
    id_list = MapSet.to_list(node_ids)

    from(r in TechRelation,
      where: r.parent_id in ^id_list and r.child_id in ^id_list,
      select: %{from: r.parent_id, to: r.child_id, type: r.relation_type}
    )
    |> Repo.all()
  end
end
