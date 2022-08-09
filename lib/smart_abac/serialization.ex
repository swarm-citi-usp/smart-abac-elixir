# Copyright (C) 2022 Geovane Fedrecheski <geonnave@gmail.com>
#               2022 Universidade de São Paulo
#               2022 LSI-TEC
#
# This file is part of the SwarmOS project, and it is subject to
# the terms and conditions of the GNU Lesser General Public License v2.1.
# See the file LICENSE in the top level directory for more details.

defmodule SmartABAC.Serialization do
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
        policies =
          Enum.map(policies, fn policy_attrs ->
            {:ok, policy} = SmartABAC.build_policy(policy_attrs)
            policy
          end)

        {:ok, policies}

      policy ->
        SmartABAC.build_policy(policy)
    end
  end

  def to_cbor(policy, binary \\ :raw) do
    policy_cbor =
      if binary == :hex do
        CBOR.encode(policy) |> Base.encode16()
      else
        CBOR.encode(policy)
      end

    {:ok, policy_cbor}
  end

  def from_cbor(policy_cbor, binary \\ :raw) do
    policy_cbor =
      if binary == :hex do
        Base.decode16!(policy_cbor)
      else
        policy_cbor
      end

    policy_cbor
    |> CBOR.decode()
    |> case do
      {:ok, policies, ""} when is_list(policies) ->
        policies =
          Enum.map(policies, fn policy_attrs ->
            {:ok, policy} = SmartABAC.build_policy(policy_attrs)
            policy
          end)

        {:ok, policies}

      {:ok, policy, ""} ->
        SmartABAC.build_policy(policy)
    end
  end
end

defimpl CBOR.Encoder, for: SmartABAC.Policy do
  def encode_into(policy, acc) do
    %{
      "id" => policy.id,
      "name" => policy.name,
      "permissions" => policy.permissions
    }
    |> CBOR.Encoder.encode_into(acc)
  end
end

defimpl CBOR.Encoder, for: SmartABAC.Rule do
  def encode_into(rule, acc) do
    %{
      "subject" => rule.subject,
      "object" => rule.object,
      "context" => rule.context,
      "operations" => rule.operations
    }
    |> CBOR.Encoder.encode_into(acc)
  end
end
