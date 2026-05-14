defmodule ProgressTree.Integration.TreeIntegrationTest do
  use ProgressTree.DataCase, async: false

  alias ProgressTree.Knowledge.Tree
  alias ProgressTree.Seeds

  setup do
    Seeds.run()
    :ok
  end

  test "descendants from 1987 prototype reach 2022 complex" do
    import Ecto.Query
    alias ProgressTree.Repo
    alias ProgressTree.Knowledge.TechGene

    root =
      Repo.one!(from g in TechGene, where: g.inventory_number == "НИИ-1987-001")

    descendants = Tree.get_descendants(root.id, 10)
    titles = Enum.map(descendants, & &1.title)

    assert "Усилитель ПЧ-400-М" in titles
    assert "Комплекс ПЧ-400-К" in titles
    assert length(descendants) >= 4
  end

  test "lineage from leaf reaches prototype" do
    import Ecto.Query
    alias ProgressTree.Repo
    alias ProgressTree.Knowledge.TechGene

    leaf =
      Repo.one!(from g in TechGene, where: g.inventory_number == "НИИ-2022-101")

    path = Tree.get_lineage_path(leaf.id)
    inv_numbers = Enum.map(path, & &1.inventory_number)

    assert "НИИ-1987-001" in inv_numbers
  end
end
