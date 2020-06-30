defmodule ABACthem.Types do
  require Logger

  def infer_type(attr) when is_map(attr) do
    [{name, value}] = Map.to_list(attr)
    infer_type(name, value)
  end

  def infer_type(name, value) do
    dt = get_type(value)
    if dt == "range" do
      value = Enum.map(value, fn {k, v} -> {String.to_atom(k), v} end) |> Enum.into(%{})
      %{data_type: dt, name: name, value: value}
    else
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
