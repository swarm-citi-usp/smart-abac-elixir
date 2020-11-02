defmodule ModelsTest do
  use ExUnit.Case
  doctest SmartABAC
  import SmartABAC.Factory
  alias SmartABAC.{Policy, Request}

  test "create policy" do
    policy_attrs = params_for(:policy)

    assert {:ok, policy = %Policy{}} = SmartABAC.create_policy(policy_attrs)
    assert :ok = SmartABAC.delete_policy(policy.id)
  end

  test "build request" do
    request_attrs = params_for(:request)

    assert {:ok, %Request{}} = SmartABAC.build_request(request_attrs)
  end

  test "expand request attributes" do
    request_attrs = params_for(:request)
    subject_attrs = Map.merge(request_attrs[:subject], %{"role" => "swarm:Mother"})
    request_attrs = put_in(request_attrs, [:subject], subject_attrs)
    {:ok, request} = SmartABAC.build_request(request_attrs)

    assert "swarm:AdultFamilyMember" in Request.add_expanded_attrs(request.subject)["role"]

    request = Request.expand_attrs(request)
    assert "swarm:AdultFamilyMember" in request.subject["role"]
  end
end
