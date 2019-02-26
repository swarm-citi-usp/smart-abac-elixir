defmodule AC.PDP do
  use AC.LogDecorator

  def authorize(request, policies) do
    policies
    |> Enum.any?(fn policy ->
      match_operations(request[:operations], policy.operations) &&
        match_attrs(request[:user_attrs], policy.user_attrs) &&
        match_attrs(request[:object_attrs], policy.object_attrs)
    end)
  end

  @doc """
  Tests whether the request attributes are allowed by a policy.

  Returns true if the set `request_ops` is a subset of `policy_ops`.
  """
  @decorate log(:debug)
  def match_attrs(request_attrs, policy_attrs) do
    policy_attrs
    |> Enum.all?(fn policy_attr ->
      Enum.any?(request_attrs, &match_attr(&1, policy_attr))
    end)
  end

  def match_attr(_request_attr = {name, value}, policy_attr = %{data_type: dt})
      when dt in ["string", "number"] do
    policy_attr.name == name and policy_attr.value == value
  end

  def match_attr(_request_attr = {name, value}, policy_attr = %{data_type: "range"}) do
    policy_attr.name == name and match_range(value, policy_attr.value)
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
  @decorate log(:debug)
  def match_operations([], _policy_ops), do: false
  def match_operations(_request_ops, []), do: false
  def match_operations(request_ops, ["all"]), do: true

  def match_operations(request_ops, policy_ops) do
    request_ops
    |> Enum.all?(&(&1 in policy_ops))
  end
end
