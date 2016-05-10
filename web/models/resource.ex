defmodule Caniuse.Resource do
  use Caniuse.Web, :model

  schema "resource" do
    field :name, :string
    field :description, :string
    field :is_locked, :boolean, default: false
    field :last_change, Ecto.DateTime
    field :changed_by, :string

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w(description is_locked last_change changed_by)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:name)
  end
end
