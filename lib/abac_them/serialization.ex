defmodule ABACthem.Serialization do
  @moduledoc """
  Serialize policies to and from json.
  """

  def to_json(policy) do
    Jason.encode(policy)
  end

  def from_json(policy_json) do
    policy_json
    |> Jason.decode!()
    |> ABACthem.build_policy()
  end
end
