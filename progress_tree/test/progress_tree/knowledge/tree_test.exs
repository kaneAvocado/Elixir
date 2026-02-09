defmodule ProgressTree.Knowledge.TreeTest do
  use ProgressTree.DataCase, async: true

  alias ProgressTree.Knowledge
  alias ProgressTree.Knowledge.Tree
  alias ProgressTree.Repo
  alias ProgressTree.Employees.Employee

  setup do
    {:ok, author} =
      %Employee{}
      |> Employee.changeset(%{full_name: "Иванов И.И.", department: "Отдел №5"})
      |> Repo.insert()

    {:ok, g1} =
      Knowledge.create_gene(%{
        title: "Усилитель ПЧ-400 прототип",
        inventory_number: "НИИ-1987-001",
        doc_type: "чертеж",
        department: "Отдел №5",
        year: 1987,
        author_id: author.id
      })

    {:ok, g2} =
      Knowledge.create_gene(%{
        title: "Усилитель ПЧ-400-1",
        inventory_number: "НИИ-2003-014",
        doc_type: "спецификация",
        department: "Отдел №5",
        year: 2003,
        author_id: author.id
      })

    {:ok, g3} =
      Knowledge.create_gene(%{
        title: "Усилитель ПЧ-400-М",
        inventory_number: "НИИ-2020-088",
        doc_type: "спецификация",
        department: "Отдел №12",
        year: 2020,
        author_id: author.id
      })

    {:ok, _} =
      Knowledge.create_relation(%{
        parent_id: g1.id,
        child_id: g2.id,
        relation_type: "наследование"
      })

    {:ok, _} =
      Knowledge.create_relation(%{
        parent_id: g2.id,
        child_id: g3.id,
        relation_type: "наследование"
      })

    %{root: g1, middle: g2, leaf: g3}
  end

  test "get_descendants returns chain from root", %{root: root, leaf: leaf} do
    descendants = Tree.get_descendants(root.id)

    assert length(descendants) == 2
    child_ids = Enum.map(descendants, & &1.child_id)
    assert leaf.id in child_ids
  end

  test "get_lineage_path returns ancestors to root", %{root: root, leaf: leaf} do
    path = Tree.get_lineage_path(leaf.id)

    assert length(path) == 2
    parent_ids = Enum.map(path, & &1.parent_id)
    assert root.id in parent_ids
  end
end
