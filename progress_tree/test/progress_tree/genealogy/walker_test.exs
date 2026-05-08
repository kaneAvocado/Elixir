defmodule ProgressTree.Genealogy.WalkerTest do
  use ProgressTree.DataCase, async: false

  alias ProgressTree.Genealogy.Walker
  alias ProgressTree.Knowledge
  alias ProgressTree.Repo
  alias ProgressTree.Employees.Employee

  setup do
    {:ok, author} =
      %Employee{}
      |> Employee.changeset(%{full_name: "Тестов Т.Т."})
      |> Repo.insert()

    genes =
      for {title, inv, year} <- [
            {"A", "НИИ-A", 1980},
            {"B", "НИИ-B", 1990},
            {"C", "НИИ-C", 2000}
          ] do
        {:ok, g} =
          Knowledge.create_gene(%{
            title: title,
            inventory_number: inv,
            doc_type: "чертеж",
            department: "Отдел",
            year: year,
            author_id: author.id
          })

        g
      end

    [a, b, c] = genes

    {:ok, _} =
      Knowledge.create_relation(%{parent_id: a.id, child_id: b.id, relation_type: "наследование"})

    {:ok, _} =
      Knowledge.create_relation(%{parent_id: b.id, child_id: c.id, relation_type: "наследование"})

    %{a: a, b: b, c: c}
  end

  test "finds common ancestor via BFS", %{a: a, c: c} do
    assert {:ok, %{common_ancestor: ancestor_id, path: path}} = Walker.bidirectional_bfs(a.id, c.id)
    assert ancestor_id == a.id
    assert a.id in path
    assert c.id in path
  end
end
