defmodule ABACthem.PDP do
  use ABACthem.LogDecorator

  @doc """
  Returns whether or not any of the `policies` allow the `request` to be executed.
  """
  def authorize(request, policies) do
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
  """
  Application.get_env(:abac_them, :debug_pdp) && @decorate log(:debug)
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
  def match_attr("time_interval", {_req_name, current_time}, policy_attr) do
    match_time_window(policy_attr.value, current_time)
  end

  def match_time_window(time_window, current_time) do
    {start_time, finish_time} = decode_time_window(time_window)
    {request_time, _} = decode_time_window(current_time)

    request_time >= start_time && request_time <= finish_time
  end

  def decode_time_window(time_window) do
    dummy_time = %DateTime{DateTime.utc_now | microsecond: {0, 0}}

    time_window
    |> String.split(~r/\s+/)
    |> Enum.zip([:second, :minute, :hour, :day, :month, :year])
    |> Enum.reduce({dummy_time, dummy_time}, fn {unit_value, unit}, {start_time, finish_time} ->
      {start, finish} = split_unit(unit_value, unit)
      {Map.put(start_time, unit, start), Map.put(finish_time, unit, finish)}
    end)
  end

  def match_time_window_wildcard(time_window, current_time) do
    [time_window, current_time]
    |> Enum.map(&String.split(&1, ~r/\s+/))
    |> Enum.zip()
    |> Enum.reverse()
    |> Enum.all?(fn {window, time} ->
      if window == "*" do
        true
      else
        {min, max} = split_unit(window)
        time = String.to_integer(time)
        time >= min && time <= max
      end
    end)
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
  def match_attr("string", {req_name, req_values}, policy_attr) when is_list(req_values) do
    req_values
    |> Enum.any?(fn req_value ->
      match_attr("string", {req_name, req_value}, policy_attr)
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
  The format for specifying time is inspired by the
  [cron time string format](http://www.nncron.ru/help/EN/working/cron-format.htm).

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

  def split_unit("*", unit) do
    %{
      second: {0, 59},
      minute: {0, 59},
      hour: {0, 23},
      day: {1, 31},
      month: {1, 12},
      year: {0, 2048*2048}
    }[unit]
  end

  def split_unit(time_unit) do
    String.split(time_unit, "-")
    |> Enum.map(&String.to_integer/1)
    |> case do
      [value] ->
        {value, value}

      [left, right] ->
        if left <= right do
          {left, right}
        else
          {right, left}
        end
    end
  end

  def split_unit(time_unit, _unit) do
    String.split(time_unit, "-")
    |> Enum.map(&String.to_integer/1)
    |> case do
      [value] ->
        {value, value}

      [left, right] ->
        {left, right}
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

  Returns true when the set `request_ops` is a subset of `policy_ops`.
  """
  Application.get_env(:abac_them, :debug_pdp) && @decorate log(:debug)
  def match_operations([], _policy_ops), do: false
  def match_operations(_request_ops, []), do: false
  def match_operations(_request_ops, ["all"]), do: true

  def match_operations(request_ops, policy_ops) do
    request_ops
    |> Enum.all?(&(&1 in policy_ops))
  end
end
