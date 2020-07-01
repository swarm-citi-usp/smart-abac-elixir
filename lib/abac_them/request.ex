defmodule ABACthem.Request do
  @moduledoc """
  Specifies a Request.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias ABACthem.{Hierarchy}

  @primary_key false
  embedded_schema do
    field(:subject, :map)
    field(:object, :map)
    field(:context, :map)
    field(:operations, {:array, :string})
  end

  def changeset(params) do
    %__MODULE__{}
    |> changeset(params)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:subject, :object, :context, :operations])
  end

  def expand_attrs(request) do
    %__MODULE__{
      request
      | subject: add_expanded_attrs(request.subject),
        object: add_expanded_attrs(request.object),
        context: add_expanded_attrs(request.context)
    }
  end

  def add_expanded_attrs(attrs) do
    attrs
    |> Enum.map(fn {attr_name, attr_value} ->
      {attr_name, expand_attr(attr_value)}
    end)
    |> Enum.into(%{})
  end

  def expand_attr(value) when not is_binary(value), do: value

  def expand_attr(value) do
    Hierarchy.expand_attr(value)
    |> Enum.map(fn attr_name ->
      # FIXME
      String.replace(attr_name, "http://iotswarm.info/ontology#", "swarm:")
    end)
  end

  def add_date_time(request) do
    {:ok, dt} = DateTime.now("America/Sao_Paulo")

    context =
      Map.merge(request.context, %{
        "dateTime" => %{
          "second" => dt.second,
          "minute" => dt.minute,
          "hour" => dt.hour,
          "day" => dt.day,
          "month" => dt.month,
          "year" => dt.year,
          "timeZone" => dt.time_zone
        }
      })

    %{request | context: context}
  end
end
