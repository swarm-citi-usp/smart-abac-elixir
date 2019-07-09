defmodule ABACthem.Request do
  defstruct user_attrs: %{}, object_attrs: %{}, context_attrs: %{}, operations: []

  @type t :: %__MODULE__{
          user_attrs: [Attr.t()],
          operations: [String.t()],
          object_attrs: [Attr.t()],
          context_attrs: [Attr.t()]
        }

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
    Application.get_env(:abac_them, :hierarchy_client).expand_attr(name, value)
    |> Enum.map(fn attr_name ->
      String.replace(attr_name, "http://br.citi.usp/swarm#", "s:")
    end)
  end

  def add_date_time_attr(request) do
    request_date_time = DateTime.utc_now() |> format_date_time()

    new_context =
      (request.context_attrs || %{})
      |> Map.put("DateTime", request_date_time)

    %{request | context_attrs: new_context}
  end

  def format_date_time(%{second: sec, minute: min, hour: hour, day: day, month: month, year: year}) do
    "#{sec} #{min} #{hour} #{day} #{month} #{year}"
  end
end
