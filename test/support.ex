defmodule AttrInspect do
  def simple_encode([]) do
    "[]"
  end

  def simple_encode(attrs) when is_list(attrs) do
    """
    [
          #{Enum.map(attrs, &simple_encode/1) |> Enum.join(",\n      ")}
        ]\
    """
  end

  def simple_encode(%{data_type: dt, name: name, value: value}) do
    "[#{dt}, #{name}, #{simple_encode(value)}]"
  end

  def simple_encode(value = %{}) do
    Poison.encode!(value)
  end

  def simple_encode(value) do
    value
  end
end

defmodule PolicyInspect do
  def inspect(policies, :json) do
    policies
    |> convert_attrs_to_list()
    |> Poison.encode!(pretty: true)
    |> IO.puts()
  end

  def inspect(policies) do
    policies
    |> simple_encode()
    |> IO.puts()
  end

  def convert_attrs_to_list(policies) when is_list(policies) do
    Enum.map(policies, &convert_attrs_to_list/1)
  end

  def convert_attrs_to_list(policy) do
    %{
      policy
      | user_attrs: Enum.map(policy.user_attrs, &attr_to_list/1),
        object_attrs: Enum.map(policy.object_attrs, &attr_to_list/1),
        context_attrs: Enum.map(policy.context_attrs, &attr_to_list/1)
    }
  end

  def attr_to_list(attr) do
    [attr.data_type, attr.name, attr.value]
  end

  def simple_encode([]) do
    "[]"
  end

  def simple_encode(policies) when is_list(policies) do
    """
    [
      #{Enum.map(policies, &simple_encode/1) |> Enum.join(",\n  ")}
    ]
    """
  end

  def simple_encode(policy) do
    """
    {
        ua: #{AttrInspect.simple_encode(policy.user_attrs)},
        op: [#{policy.operations |> Enum.join(", ")}],
        oa: #{AttrInspect.simple_encode(policy.object_attrs)},
        ca: #{AttrInspect.simple_encode(policy.context_attrs)}
      }\
    """
  end
end
