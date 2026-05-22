defmodule ProgressTreeWeb.PageControllerTest do
  use ProgressTreeWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "ProgressTree"
  end
end
