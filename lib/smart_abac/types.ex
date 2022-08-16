# Copyright (C) 2022 Geovane Fedrecheski <geonnave@gmail.com>
#               2022 Universidade de São Paulo
#               2022 LSI-TEC
#
# This file is part of the SwarmOS project, and it is subject to
# the terms and conditions of the GNU Lesser General Public License v2.1.
# See the file LICENSE in the top level directory for more details.

defmodule SmartABAC.Types do
  require Logger

  defmodule Attr do
    defstruct data_type: "string", name: "", value: ""
  end

  alias SmartABAC.Types.Attr

  def infer_type(attr \\ %{}, recursive \\ false)

  def infer_type(attr, recursive) when is_map(attr) do
    attr
    |> Enum.map(fn {name, value} -> do_infer_type(name, value, recursive) end)
  end

  def infer_type({name, value}, recursive), do: do_infer_type(name, value, recursive)

  def do_infer_type(name, value, recursive) do
    dt = get_type(value)

    case dt do
      "range" ->
        value = Enum.map(value, fn {k, v} -> {String.to_atom(k), v} end) |> Enum.into(%{})
        %Attr{data_type: dt, name: name, value: value}

      "object" ->
        if recursive do
          %Attr{data_type: dt, name: name, value: infer_type(value)}
        else
          %Attr{data_type: dt, name: name, value: value}
        end

      _ ->
        %Attr{data_type: dt, name: name, value: value}
    end
  end

  def get_type(value) when is_number(value), do: "number"
  def get_type(value) when is_binary(value), do: "string"

  def get_type(value) when is_map(value) do
    keys = Map.keys(value)
    rest = ["min", "max"] -- keys

    if length(rest) < 2 do
      "range"
    else
      "object"
    end
  end
end
