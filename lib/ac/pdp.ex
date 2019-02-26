defmodule AC.PDP do
  def authorize(_request) do
    false
  end

  def match_attrs(request_attrs, policy_attrs) do
    policy_attrs
    |> Enum.all?(fn policy_attr ->
      Enum.any?(request_attrs, &match_attr(&1, policy_attr))
    end)
  end

  def match_attr(_request_attr = {key, value}, policy_attr) do
    policy_attr.name == key and policy_attr.value == value
  end
end
