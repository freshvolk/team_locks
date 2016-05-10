defmodule Caniuse.PageController do
  use Caniuse.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
