defmodule AC.PDP do
  use AC.LogDecorator

  @hierarchy_client Application.get_env(:ac, :hierarchy_client)

  @doc """
  Returns whether or not any of the `policies` allow the `request` to be executed.
  """
  def authorize(request, policies) do
    request = AC.Request.expand_attrs(request)

    policies
    |> Enum.any?(fn policy ->
      match_operations(request.operations, policy.operations) &&
        match_attrs(request.user_attrs, policy.user_attrs) &&
        match_attrs(request.object_attrs, policy.object_attrs) &&
        match_attrs(request.context_attrs, policy.context_attrs)
    end)
  end

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
  Checks whether a number, provided by the request, is within a range, specified in the policy.
  """
  def match_attr("range", {req_name, req_value}, policy_attr) do
    policy_attr.name == req_name and match_range(req_value, policy_attr.value)
  end

  @doc """
  Checks whether a date-time, provided by the request, is within a time window, specified in the policy.
  """
  def match_attr("time_window", {_req_name, current_time}, policy_attr) do
    [String.split(current_time, ~r/\s+/), String.split(policy_attr.value, ~r/\s+/)]
    |> List.zip()
    |> Enum.all?(fn {value, window} -> in_time_range?(value, window) end)
  end

  @doc """
  Compares a number, provided by the request, with another number, specified in the policy.
  """
  def match_attr("number", {req_name, req_value}, policy_attr) do
    policy_attr.name == req_name and policy_attr.value == req_value
  end

  @doc """
  Compares *container* attributes, from the request, against string attributes defined in the policy.
  """
  def match_attr("string", {"__containers__", request_attr_containers}, policy_attr) do
    request_attr_containers
    |> Enum.any?(fn request_attr_container ->
      request_attr_container == policy_attr.value
    end)
  end

  @doc """
  Compares a string, provided by the request, against another string, specified in the policy.
  """
  def match_attr("string", {req_name, req_value}, policy_attr) do
    policy_attr.name == req_name and policy_attr.value == req_value
  end

  @doc """
  Matches a date-time value against a time range.
  The format for specifying time is inspired by the [cron time string format](http://www.nncron.ru/help/EN/working/cron-format.htm).

  # Examples

    iex> in_tine_range?("0 0 5  1 1 2019", "* * 6-22 * * *")
    false
    iex> in_tine_range?("0 0 8  1 1 2019", "* * 6-22 * * *")
    true
  """
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
