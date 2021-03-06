defmodule Caniuse.ResourceControllerTest do
  use Caniuse.ConnCase

  alias Caniuse.Resource
  @valid_attrs %{changed_by: "some content", description: "some content", is_locked: true, last_change: "2010-04-17 14:00:00", name: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, resource_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    resource = Repo.insert! %Resource{}
    conn = get conn, resource_path(conn, :show, resource)
    assert json_response(conn, 200)["data"] == %{"id" => resource.id,
      "name" => resource.name,
      "description" => resource.description,
      "is_locked" => resource.is_locked,
      "last_change" => resource.last_change,
      "changed_by" => resource.changed_by}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, resource_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, resource_path(conn, :create), resource: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Resource, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, resource_path(conn, :create), resource: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    resource = Repo.insert! %Resource{}
    conn = put conn, resource_path(conn, :update, resource), resource: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Resource, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    resource = Repo.insert! %Resource{}
    conn = put conn, resource_path(conn, :update, resource), resource: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    resource = Repo.insert! %Resource{}
    conn = delete conn, resource_path(conn, :delete, resource)
    assert response(conn, 204)
    refute Repo.get(Resource, resource.id)
  end
end
