defmodule ProgressTree.Knowledge.Search do
  @moduledoc "ILIKE search over tech genes by title and inventory number."

  import Ecto.Query
  alias ProgressTree.Repo
  alias ProgressTree.Knowledge.TechGene

  def search_genes(query, limit \\ 20) when is_binary(query) do
    trimmed = String.trim(query)

    if trimmed == "" do
      []
    else
      pattern = "%#{trimmed}%"

      TechGene
      |> where(
        [g],
        ilike(g.title, ^pattern) or ilike(g.inventory_number, ^pattern)
      )
      |> order_by([g], asc: g.title)
      |> limit(^limit)
      |> Repo.all()
    end
  end
end
