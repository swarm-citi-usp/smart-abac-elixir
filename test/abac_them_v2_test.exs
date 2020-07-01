defmodule ABACthemV2Test do
  use ExUnit.Case
  import ABACthem.Factory

  test "authorize with regular policy" do
    {:ok, _policy} = params_for(:policy) |> ABACthem.create_policy()
    {:ok, request} = params_for(:request) |> ABACthem.build_request()

    assert ABACthem.authorize_v2(request)
  end
end
