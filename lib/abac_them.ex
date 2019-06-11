defmodule ABACthem do
  @moduledoc """
  Documentation for ABACthem.
  """

  @hierarchy_client Application.get_env(:abac_them, :hierarchy_client)

  def expand_to_contained_attrs(attr) do
    attr.value
    |> @hierarchy_client.get_contained_attrs()
    |> Enum.map(fn container_attr_value ->
      %ABACthem.Attr{data_type: attr.data_type, name: attr.name, value: container_attr_value}
    end)
  end

  def replace_attr(attrs, orig_attr, other_attr) do
    attrs
    |> Enum.reject(fn attr -> attr == orig_attr end)
    |> Enum.concat([other_attr])
  end
end
