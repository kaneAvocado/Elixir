defmodule ProgressTreeWeb.GenealogyLive.IndexTest do
  use ProgressTreeWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  alias ProgressTree.Knowledge
  alias ProgressTree.Repo
  alias ProgressTree.Employees.Employee

  setup do
    {:ok, author} =
      %Employee{}
      |> Employee.changeset(%{full_name: "Петров П.П."})
      |> Repo.insert()

    {:ok, gene} =
      Knowledge.create_gene(%{
        title: "Усилитель ПЧ-400",
        inventory_number: "НИИ-2003-014",
        doc_type: "спецификация",
        department: "Отдел №5",
        year: 2003,
        author_id: author.id
      })

    %{gene: gene}
  end

  test "renders catalog", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")

    assert html =~ "ProgressTree"
    assert html =~ "Усилитель ПЧ-400"
  end

  test "search filters results", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    html =
      view
      |> form("form", %{query: "ПЧ-400"})
      |> render_change()

    assert html =~ "НИИ-2003-014"
  end
end
