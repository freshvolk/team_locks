defmodule Caniuse.ResourceTest do
  use Caniuse.ModelCase

  alias Caniuse.Resource

  @valid_attrs %{changed_by: "some content", description: "some content", is_locked: true, last_change: "2010-04-17 14:00:00", name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Resource.changeset(%Resource{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Resource.changeset(%Resource{}, @invalid_attrs)
    refute changeset.valid?
  end
end
