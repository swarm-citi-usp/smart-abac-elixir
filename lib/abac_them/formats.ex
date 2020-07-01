defmodule ABACthem.Formats do
  require Logger

  def from_new_to_old(policy) do
    %{
      id: policy[:id],
      name: policy[:name],
      user_attrs: infer_types(policy[:privileges][:subject]),
      object_attrs: infer_types(policy[:privileges][:object]),
      context_attrs: infer_types(policy[:privileges][:context]),
      operations: policy[:privileges][:operations]
    }
  end

  def infer_types(nil), do: []
  def infer_types(attrs) do
    attrs
    |> Enum.map(fn {name, value} ->
      infer_type(name, value)
    end)
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

  def from_old_to_new(policy) do
    %{
      version: "2",
      id: policy[:id],
      name: policy[:name],
      privileges: %{
        subject: to_new_attrs(policy[:user_attrs]),
        object: to_new_attrs(policy[:object_attrs]),
        context: to_new_attrs(policy[:context_attrs]),
        operations: policy.operations
      }
    }
  end

  def to_new_attrs(nil), do: []
  def to_new_attrs(attrs) do
    attrs
    |> Enum.map(&to_new_attr/1)
    |> Enum.reduce(fn x, acc -> Map.merge(x, acc) end)
  end

  def to_new_attr(%{data_type: dt, name: name, value: value}) do
    value =
      if dt == "range" do
        value |> Poison.encode! |> Poison.decode!
      else
        value
      end

    Map.put(%{}, name, value)
  end
end
