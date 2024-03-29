# Copyright (C) 2022 Geovane Fedrecheski <geonnave@gmail.com>
#               2022 Universidade de São Paulo
#               2022 LSI-TEC
#
# This file is part of the SwarmOS project, and it is subject to
# the terms and conditions of the GNU Lesser General Public License v2.1.
# See the file LICENSE in the top level directory for more details.

defmodule SmartABAC.Request do
  @moduledoc """
  Specifies a Request.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias SmartABAC.{Hierarchy}

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

  def expand_attrs(request) do
    request
    |> Map.put(:subject, add_expanded_attrs(request.subject))
    |> Map.put(:object, add_expanded_attrs(request.object))
    |> Map.put(:context, add_expanded_attrs(request.context))
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
