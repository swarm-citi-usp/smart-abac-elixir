defmodule ABACthemV2Test do
  use ExUnit.Case
  import ABACthem.Factory
  alias ABACthem.{Hierarchy}

  setup do
    ABACthem.Store.reset()

    :ok
  end

  test "authorize with regular policy" do
    {:ok, _policy} = params_for(:policy) |> ABACthem.create_policy()
    {:ok, request} = params_for(:request) |> ABACthem.build_request()

    assert ABACthem.authorize_v2(request)
  end

  test "authorize based on hierarchy" do
    Hierarchy.set_graph("example_home_policy.n3")

    {:ok, _policy} =
      params_for(:policy)
      |> put_in([:privileges, :subject], %{"role" => "swarm:AdultFamilyMember"})
      |> ABACthem.create_policy()

    {:ok, request} =
      params_for(:request)
      |> put_in([:subject], %{"role" => "swarm:Mother"})
      |> ABACthem.build_request()

    assert ABACthem.authorize_v2(request)
  end
end
