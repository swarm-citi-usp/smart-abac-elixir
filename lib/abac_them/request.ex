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
      | user_attrs: add_expanded_attrs(request.user_attrs),
        object_attrs: add_expanded_attrs(request.object_attrs),
        context_attrs: add_expanded_attrs(request.context_attrs)
    }
  end

  def add_expanded_attrs(attrs) do
    attrs
    |> Enum.map(fn {attr_name, attr_value} ->
      {attr_name, expand_attr(attr_name, attr_value)}
    end)
    |> Enum.into(%{})
  end

  def expand_attr(_name, value) when not is_binary(value), do: value

  def expand_attr(name, value) do
    @hierarchy_client.expand_attr(name, value)
    |> Enum.map(fn attr_name ->
      String.replace(attr_name, "http://br.citi.usp/swarm#", "s:")
    end)
  end
end
