defmodule ProgressTreeWeb.GenealogyLive.ShowTest do
  use ProgressTreeWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  alias ProgressTree.Knowledge
  alias ProgressTree.Repo
  alias ProgressTree.Employees.Employee

  setup do
    {:ok, author} =
      %Employee{}
      |> Employee.changeset(%{full_name: "Сидоров С.С."})
      |> Repo.insert()

    {:ok, gene} =
      Knowledge.create_gene(%{
        title: "Модуль питания МП-12",
        inventory_number: "НИИ-2015-042",
        doc_type: "чертеж",
        department: "Лаборатория 3",
        year: 2015,
        author_id: author.id
      })

    %{gene: gene}
  end

  test "mounts show page", %{conn: conn, gene: gene} do
    {:ok, _view, html} = live(conn, ~p"/genealogy/#{gene.id}")

    assert html =~ "Модуль питания МП-12"
    assert html =~ "НИИ-2015-042"
  end

  test "select_node navigates", %{conn: conn, gene: gene} do
    {:ok, other} =
      Knowledge.create_gene(%{
        title: "Другая разработка",
        inventory_number: "НИИ-2016-001",
        doc_type: "отчет",
        department: "Отдел №1",
        year: 2016
      })

    {:ok, view, _} = live(conn, ~p"/genealogy/#{gene.id}")

    view |> form("form", %{query: "Другая"}) |> render_change()

    assert {:error, {:live_redirect, %{to: "/genealogy/" <> id}}} =
             view
             |> element("button[phx-value-id='#{other.id}']")
             |> render_click()

    assert id == "#{other.id}"
  end
end
