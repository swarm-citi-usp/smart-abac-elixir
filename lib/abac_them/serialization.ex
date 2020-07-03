defmodule ABACthem.Serialization do
  @moduledoc """
  Serialize policies to and from json.
  """

  def to_json(policy, opts \\ []) do
    Jason.encode(policy, opts)
  end

  def from_json(policy_json) do
    policy_json
    |> Jason.decode!()
    |> case do
      policies when is_list(policies) ->
        policies = Enum.map(policies, fn policy_attrs ->
          {:ok, policy} = ABACthem.build_policy(policy_attrs)
          policy
        end)
        {:ok, policies}
      policy ->
        ABACthem.build_policy(policy)
    end
  end
end
