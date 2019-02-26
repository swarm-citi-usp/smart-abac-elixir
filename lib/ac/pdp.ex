defmodule AC.PDP do
  def authorize(_request) do
    false
  end

  @doc """
  Tests whether the request attributes are allowed by a policy.

  Returns true if the set `request_ops` is a subset of `policy_ops`.
  """
  def match_attrs(request_attrs, policy_attrs) do
    policy_attrs
    |> Enum.all?(fn policy_attr ->
      Enum.any?(request_attrs, &match_attr(&1, policy_attr))
    end)
  end

  def match_attr(_request_attr = {key, value}, policy_attr) do
    policy_attr.name == key and policy_attr.value == value
  end

  @doc """
  Tests whether the request operations are allowed by a policy.

  Returns true if the set `request_ops` is a subset of `policy_ops`.
  """
  def match_operations([], _policy_ops), do: false
  def match_operations(_request_ops, []), do: false

  def match_operations(request_ops, policy_ops) do
    request_ops
    |> Enum.all?(&(&1 in policy_ops))
  end
end
