defmodule ABACthem.Rule do
  @moduledoc """
  Specifies a Rule.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :subject, :map
    field :object, :map
    field :context, :map
    field :operations, {:array, :string}
  end

  def changeset(params) do
    %__MODULE__{}
    |> changeset(params)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:subject, :object, :context, :operations])
  end
end
