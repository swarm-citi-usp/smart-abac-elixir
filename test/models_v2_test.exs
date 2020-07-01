defmodule PolicyTest do
  use ExUnit.Case
  doctest ABACthem
  import ABACthem.Factory
  alias ABACthem.{Policy, Request}

  test "create policy" do
    policy_attrs = params_for(:policy)

    assert {:ok, policy = %Policy{}} = ABACthem.create_policy(policy_attrs)
    assert :ok = ABACthem.delete_policy(policy.id)
  end

  test "build request" do
    request_attrs = params_for(:request)

    assert {:ok, %Request{}} = ABACthem.build_request(request_attrs)
  end

  test "expand request attributes" do
    request_attrs = params_for(:request)
    subject_attrs = Map.merge(request_attrs[:subject], %{"role" => "swarm:Mother"})
    request_attrs = put_in(request_attrs, [:subject], subject_attrs)
    {:ok, request} = ABACthem.build_request(request_attrs)

    assert "swarm:AdultFamilyMember" in Request.add_expanded_attrs(request.subject)["role"]

    request = Request.expand_attrs(request)
    assert "swarm:AdultFamilyMember" in request.subject["role"]
  end
end
