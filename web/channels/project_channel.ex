defmodule Caniuse.ProjectChannel do
  require Logger
  use Caniuse.Web, :channel
  alias Caniuse.Resource, as: Resource

  def join("projects:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def join("project:" <> project_name, payload, socket) do
    case Caniuse.Repo.get_by(Resource, name: project_name) do
      nil ->
        {:ok, resource} = Caniuse.Repo.insert(%Resource{name: project_name})
        {:ok, resource_to_map(resource), socket}
      resource ->
        {:ok, resource_to_map(resource), socket}
    end
  end

  def handle_in("lock:resource:" <> resource_name, _payload, socket) do
    changeset = Resource.changeset(Caniuse.Repo.get_by(Resource, name: resource_name), %{"is_locked" => true})
    {:ok, resource} = Caniuse.Repo.update(changeset)
    broadcast socket, "update",  resource_to_map(resource)
    {:noreply, socket}
  end

  def handle_in("unlock:resource:" <> resource_name, _payload, socket) do
    changeset = Resource.changeset(Caniuse.Repo.get_by(Resource, name: resource_name), %{"is_locked" => false})
    {:ok, resource} = Caniuse.Repo.update(changeset)
    broadcast socket, "update",  resource_to_map(resource)
    {:noreply, socket}
  end

  def broadcast_change(resource_name, lock_status) do
    broadcast "project:#{resource_name}", "update", %{ "locked" => lock_status}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (projects:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  defp resource_to_map(resource) do
    %{  "name" => resource.name,
        "changed_by" => resource.changed_by,
        "description" => resource.description,
        "id" => resource.id,
        "is_locked" => resource.is_locked,
        "updated_at" => resource.updated_at
      }
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
