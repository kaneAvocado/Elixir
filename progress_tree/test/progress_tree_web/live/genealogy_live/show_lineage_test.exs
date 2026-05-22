defmodule ProgressTreeWeb.GenealogyLive.ShowLineageTest do
  use ProgressTreeWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  alias ProgressTree.Knowledge
  alias ProgressTree.Repo
  alias ProgressTree.Employees.Employee

  setup do
    {:ok, author} =
      %Employee{}
      |> Employee.changeset(%{full_name: "Козлов К.К."})
      |> Repo.insert()

    {:ok, root} =
      Knowledge.create_gene(%{
        title: "Корень",
        inventory_number: "НИИ-1990-001",
        doc_type: "чертеж",
        department: "Отдел №1",
        year: 1990,
        author_id: author.id
      })

    {:ok, leaf} =
      Knowledge.create_gene(%{
        title: "Потомок",
        inventory_number: "НИИ-2010-010",
        doc_type: "спецификация",
        department: "Отдел №1",
        year: 2010,
        author_id: author.id
      })

    {:ok, _} =
      Knowledge.create_relation(%{
        parent_id: root.id,
        child_id: leaf.id,
        relation_type: "наследование"
      })

    %{root: root, leaf: leaf}
  end

  test "show_lineage updates ancestry_path", %{conn: conn, leaf: leaf, root: root} do
    {:ok, view, _html} = live(conn, ~p"/genealogy/#{leaf.id}")

    html =
      view
      |> element("button", "Показать цепочку наследования")
      |> render_click()

    assert html =~ "Корень"
    assert html =~ "Предки"
  end
end
