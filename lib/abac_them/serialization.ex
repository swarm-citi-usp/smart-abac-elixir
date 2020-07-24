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

  def to_cbor(policy) do
    CBOR.encode(policy)
  end

  def from_cbor(policy_cbor) do
    policy_cbor
    |> CBOR.decode()
    |> case do
      {:ok, policies, ""} when is_list(policies) ->
        policies = Enum.map(policies, fn policy_attrs ->
          {:ok, policy} = ABACthem.build_policy(policy_attrs)
          policy
        end)
        {:ok, policies}
      {:ok, policy, ""} ->
        ABACthem.build_policy(policy)
    end
  end
end

defimpl CBOR.Encoder, for: ABACthem.Policy do
  def encode_into(policy, acc) do
    %{
      "id" => policy.id,
      "name" => policy.name,
      "permissions" => policy.permissions
    } |> CBOR.Encoder.encode_into(acc)
  end
end

defimpl CBOR.Encoder, for: ABACthem.Rule do
  def encode_into(rule, acc) do
    %{
      "subject" => rule.subject,
      "object" => rule.object,
      "context" => rule.context,
      "operations" => rule.operations,
    } |> CBOR.Encoder.encode_into(acc)
  end
end
