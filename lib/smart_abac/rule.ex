defmodule SmartABAC.Rule do
  @moduledoc """
  Specifies a Rule.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:subject, :object, :context, :operations]}

  @primary_key false
  embedded_schema do
    field(:subject, :map, default: %{})
    field(:object, :map, default: %{})
    field(:context, :map, default: %{})
    field(:operations, {:array, {:map, :string}}, default: [])
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
