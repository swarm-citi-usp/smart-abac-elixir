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
end
