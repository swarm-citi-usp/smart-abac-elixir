defmodule ABACthemTest do
  use ExUnit.Case
  import ABACthem.Factory
  alias ABACthem.{HierarchyStore, Serialization}

  setup do
    ABACthem.Store.reset()

    :ok
  end

  test "authorize with regular policy" do
    {:ok, _policy} = params_for(:policy) |> ABACthem.create_policy()
    {:ok, request} = params_for(:request) |> ABACthem.build_request()

    assert ABACthem.authorize(request)
  end

  test "authorize based on hierarchy" do
    HierarchyStore.set_graph_from_file("example_home_policy.n3")

    {:ok, _policy} =
      params_for(:policy)
      |> put_in([:permissions, :subject], %{"role" => "swarm:AdultFamilyMember"})
      |> ABACthem.create_policy()

    {:ok, request} =
      params_for(:request)
      |> put_in([:subject], %{"role" => "swarm:Mother"})
      |> ABACthem.build_request()

    assert ABACthem.authorize(request)
  end

  test "json serialization" do
    {:ok, policy} = params_for(:policy) |> ABACthem.build_policy()

    {:ok, policy_json} = Serialization.to_json(policy)
    assert is_binary(policy_json)

    assert {:ok, ^policy} = Serialization.from_json(policy_json)
  end
end
