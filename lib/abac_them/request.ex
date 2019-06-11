defmodule ABACthem.Request do
  defstruct user_attrs: %{}, object_attrs: %{}, context_attrs: %{}, operations: []

  @type t :: %__MODULE__{
          user_attrs: [Attr.t()],
          operations: [String.t()],
          object_attrs: [Attr.t()],
          context_attrs: [Attr.t()]
        }

  @hierarchy_client Application.get_env(:abac_them, :hierarchy_client)

  def expand_attrs(request) do
    %__MODULE__{
      request
      | user_attrs: add_attr_containers(request.user_attrs),
        object_attrs: add_attr_containers(request.object_attrs),
        context_attrs: add_attr_containers(request.context_attrs)
    }
  end

  def add_attr_containers(attrs) do
    containers =
      attrs
      |> Enum.flat_map(fn {_attr_name, attr_value} ->
        @hierarchy_client.get_attr_containers(attr_value)
        |> Enum.map(&String.replace(&1, "http://br.citi.usp/swarm#", "s:"))
      end)

    Map.put(attrs, "__containers__", containers)
  end
end
