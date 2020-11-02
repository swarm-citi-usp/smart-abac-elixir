defmodule SmartABACTest do
  use ExUnit.Case
  import SmartABAC.Factory
  alias SmartABAC.{HierarchyStore, Serialization}

  setup do
    SmartABAC.Store.reset()

    :ok
  end

  test "authorize with regular policy" do
    {:ok, _policy} = params_for(:policy) |> SmartABAC.create_policy()
    {:ok, request} = params_for(:request) |> SmartABAC.build_request()

    assert SmartABAC.authorize(request)
  end

  test "authorize based on hierarchy" do
    HierarchyStore.set_graph_from_file("example_home_policy.n3")

    {:ok, _policy} =
      params_for(:policy)
      |> put_in([:permissions, :subject], %{"role" => "swarm:AdultFamilyMember"})
      |> SmartABAC.create_policy()

    {:ok, request} =
      params_for(:request)
      |> put_in([:subject], %{"role" => "swarm:Mother"})
      |> SmartABAC.build_request()

    assert SmartABAC.authorize(request)
  end

  test "json serialization" do
    {:ok, policy} = params_for(:policy) |> SmartABAC.build_policy()

    {:ok, policy_json} = Serialization.to_json(policy)
    assert is_binary(policy_json)

    assert {:ok, ^policy} = Serialization.from_json(policy_json)
  end

  test "cbor serialization" do
    {:ok, policy} = params_for(:policy) |> SmartABAC.build_policy()

    {:ok, policy_cbor} = Serialization.to_cbor(policy)
    assert is_binary(policy_cbor)

    {:ok, policy_back} = Serialization.from_cbor(policy_cbor)
    assert is_map(policy_back)
    assert ^policy = policy_back
  end
end
