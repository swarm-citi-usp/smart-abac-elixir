defmodule ABACthem.Types do
  require Logger

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
        %{data_type: dt, name: name, value: value}
      "object" ->
        if recursive do
          %{data_type: dt, name: name, value: infer_type(value)}
        else
          %{data_type: dt, name: name, value: value}
        end
      _ ->
        %{data_type: dt, name: name, value: value}
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
