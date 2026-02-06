defmodule ProgressTree.Knowledge.Tree do
  @moduledoc """
  Recursive CTE queries for traversing the tech genealogy graph.

  Relation types: наследование, вдохновение, сборка, форк.
  """

  alias ProgressTree.Repo

  def get_descendants(gene_id, max_depth \\ 10) do
    """
    WITH RECURSIVE descendants AS (
      SELECT child_id, relation_type, 1 AS depth
      FROM tech_relations
      WHERE parent_id = $1
      UNION ALL
      SELECT tr.child_id, tr.relation_type, d.depth + 1
      FROM tech_relations tr
      INNER JOIN descendants d ON d.child_id = tr.parent_id
      WHERE d.depth < $2
    )
    SELECT d.child_id, d.relation_type, d.depth,
           tg.title, tg.inventory_number, tg.doc_type, tg.department, tg.year, tg.status
    FROM descendants d
    JOIN tech_genes tg ON tg.id = d.child_id
    ORDER BY d.depth, tg.title
    """
    |> query_rows([gene_id, max_depth])
  end

  def get_lineage_path(gene_id, max_depth \\ 20) do
    """
    WITH RECURSIVE ancestors AS (
      SELECT parent_id, child_id, relation_type, 0 AS depth
      FROM tech_relations
      WHERE child_id = $1
      UNION ALL
      SELECT tr.parent_id, tr.child_id, tr.relation_type, a.depth + 1
      FROM tech_relations tr
      INNER JOIN ancestors a ON a.parent_id = tr.child_id
      WHERE a.depth < $2
    )
    SELECT a.parent_id, a.child_id, a.relation_type, a.depth,
           tg.title, tg.inventory_number, tg.doc_type, tg.department, tg.year, tg.status
    FROM ancestors a
    JOIN tech_genes tg ON tg.id = a.parent_id
    ORDER BY a.depth DESC
    """
    |> query_rows([gene_id, max_depth])
  end

  defp query_rows(sql, params) do
    case Repo.query(sql, params) do
      {:ok, %{columns: columns, rows: rows}} ->
        Enum.map(rows, &row_to_map(columns, &1))

      {:error, err} ->
        raise "Tree query failed: #{inspect(err)}"
    end
  end

  defp row_to_map(columns, row) do
    columns
    |> Enum.zip(row)
    |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
  end
end
