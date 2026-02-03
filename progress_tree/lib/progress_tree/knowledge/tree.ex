defmodule ProgressTree.Knowledge.Tree do
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
           tg.title, tg.inventory_number, tg.doc_type, tg.department
    FROM descendants d
    JOIN tech_genes tg ON tg.id = d.child_id
    ORDER BY d.depth
    """
    |> Ecto.Adapters.SQL.query!(Repo, [gene_id, max_depth])
  end
end
