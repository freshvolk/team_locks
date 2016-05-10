defmodule Caniuse.ResourceView do
  use Caniuse.Web, :view

  def render("index.json", %{resource: resource}) do
    %{data: render_many(resource, Caniuse.ResourceView, "resource.json")}
  end

  def render("show.json", %{resource: resource}) do
    %{data: render_one(resource, Caniuse.ResourceView, "resource.json")}
  end

  def render("resource.json", %{resource: resource}) do
    %{id: resource.id,
      name: resource.name,
      description: resource.description,
      is_locked: resource.is_locked,
      last_change: resource.last_change,
      changed_by: resource.changed_by}
  end
end
