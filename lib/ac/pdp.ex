defmodule AC.PDP do
  use AC.LogDecorator

  @hierarchy_client Application.get_env(:ac, :hierarchy_client)

  def authorize(request, policies) do
    policies
    |> Enum.any?(fn policy ->
      match_operations(request[:operations], policy.operations) &&
        match_attrs(request[:user_attrs], policy.user_attrs) &&
        match_attrs(request[:object_attrs], policy.object_attrs) &&
        match_attrs(request[:context_attrs], policy.context_attrs)
    end)
  end

  # def enhance_request_attrs(request) do
  # end

  @doc """
  Tests whether the request attributes are allowed by a policy.

  Returns true if the set `request_ops` is a subset of `policy_ops`.
  """
  # @decorate log(:debug)
  def match_attrs(request_attrs, policy_attrs) do
    policy_attrs
    |> Enum.all?(fn policy_attr ->
      Enum.any?(request_attrs, &match_attr(policy_attr.data_type, &1, policy_attr))
    end)
  end

  @doc """
  Match one request attribute against one attribute defined in a policy.
  """
  def match_attr("range", _request_attr = {name, value}, policy_attr) do
    policy_attr.name == name and match_range(value, policy_attr.value)
  end

  def match_attr("time_window", _request_attr = {_name, current_time}, policy_attr) do
    [String.split(current_time, ~r/\s+/), String.split(policy_attr.value, ~r/\s+/)]
    |> List.zip()
    |> Enum.all?(fn {value, window} -> in_time_range?(value, window) end)
  end

  def match_attr("number", _request_attr = {name, value}, policy_attr) do
    policy_attr.name == name and policy_attr.value == value
  end

  def match_attr("string", request_attr, policy_attr) do
    match_attr("flat_string", request_attr, policy_attr) ||
      match_attr_containers(request_attr, policy_attr)
  end

  def match_attr("flat_string", _request_attr = {name, value}, policy_attr) do
    policy_attr.name == name and policy_attr.value == value
  end

  @doc false
  def match_contained_attrs({_, request_attr_value}, %{value: policy_attr_value}) do
    @hierarchy_client.get_contained_attrs(policy_attr_value)
    |> Enum.any?(fn policy_attr_container ->
      policy_attr_container == request_attr_value
    end)
  end

  def match_attr_containers({_, request_attr_value}, %{value: policy_attr_value}) do
    @hierarchy_client.get_attr_containers(request_attr_value)
    |> Enum.any?(fn request_attr_container ->
      request_attr_container == policy_attr_value
    end)
  end

  def in_time_range?(_value, "*"), do: true

  def in_time_range?(value, range) do
    value = String.to_integer(value)

    String.split(range, "-")
    |> Enum.map(&String.to_integer/1)
    |> case do
      [exact_value] ->
        exact_value == value

      [left, right] ->
        if left <= right do
          value >= left && value <= right
        else
          value >= left || value <= right
        end
    end
  end

  @doc """
  Match a numerical value against a range defined as a map.
  """
  def match_range(value, range) do
    case range do
      %{min: min, max: max} ->
        value >= min && value <= max

      %{min: min} ->
        value >= min

      %{max: max} ->
        value <= max

      _ ->
        false
    end
  end

  @doc """
  Tests whether the request operations are allowed by a policy.

  Returns true if the set `request_ops` is a subset of `policy_ops`.
  """
  # @decorate log(:debug)
  def match_operations([], _policy_ops), do: false
  def match_operations(_request_ops, []), do: false
  def match_operations(_request_ops, ["all"]), do: true

  def match_operations(request_ops, policy_ops) do
    request_ops
    |> Enum.all?(&(&1 in policy_ops))
  end
end
