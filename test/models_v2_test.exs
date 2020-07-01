defmodule PolicyV2Test do
  use ExUnit.Case
  doctest ABACthem
  import ABACthem.Factory
  alias ABACthem.{PolicyV2, RequestV2}

  test "create policy" do
    policy_attrs = params_for(:policy)

    assert {:ok, policy = %PolicyV2{}} = ABACthem.create_policy(policy_attrs)
    assert :ok = ABACthem.delete_policy(policy.id)
  end

  test "build request" do
    request_attrs = params_for(:request)

    assert {:ok, %RequestV2{}} = ABACthem.build_request(request_attrs)
  end

  test "expand request attributes" do
    request_attrs = params_for(:request)
    subject_attrs = Map.merge(request_attrs[:subject], %{"role" => "swarm:Mother"})
    request_attrs = put_in(request_attrs, [:subject], subject_attrs)
    {:ok, request} = ABACthem.build_request(request_attrs)

    assert "swarm:AdultFamilyMember" in RequestV2.add_expanded_attrs(request.subject)["role"]

    request = RequestV2.expand_attrs(request)
    assert "swarm:AdultFamilyMember" in request.subject["role"]
  end
end
