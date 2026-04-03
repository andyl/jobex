defmodule JobexWeb.ErrorHTMLTest do
  use JobexWeb.ConnCase, async: true

  test "renders 404.html" do
    assert JobexWeb.ErrorHTML.render("404.html", []) == "Not Found"
  end

  test "renders 500.html" do
    assert JobexWeb.ErrorHTML.render("500.html", []) == "Internal Server Error"
  end
end
