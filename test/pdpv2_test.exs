defmodule PDPv2Test do
  use ExUnit.Case
  import ABACthem.Factory
  alias ABACthem.{Serialization, PDPv2}

  describe "authorizations" do
    test "authorize with regular policy" do
      {:ok, new_policy} = params_for(:policy) |> ABACthem.create_policy()
      {:ok, request} = params_for(:request) |> ABACthem.build_request()

      assert PDPv2.authorize(request, [new_policy])
      refute PDPv2.authorize(%{request | operations: ["teleport"]}, [new_policy])
    end

    test "authorize, policy with nested object" do
      {:ok, new_policy} =
        params_for(:policy)
        |> put_in([:privileges, :object], %{"type" => "camera", "geolocation" => %{"street" => "Rua Ceslau Marcelo Swartz", "number" => 214}})
        |> put_in([:privileges, :context], %{})
        |> ABACthem.create_policy()

      {:ok, request} =
        params_for(:request)
        |> put_in([:object], %{"type" => "camera", "geolocation" => %{"street" => "Rua Ceslau Marcelo Swartz", "number" => 214}})
        |> ABACthem.build_request()

      assert PDPv2.authorize(request, [new_policy])

      request = %{request | object: %{"owner" => "camera", "geolocation" => %{"street" => "Rua dos Bobos"}}}
      refute PDPv2.authorize(request, [new_policy])
    end
  end



  # to-do: deprecate?
  describe "conversion tests" do
    test "convert" do
      old_policy = %{
        id: "...",
        name: "alice's policy",
        user_attrs: [
          %{data_type: "string", name: "id", value: "alice"}
        ],
        operations: ["create", "read", "update", "delete"],
        object_attrs: [
          %{data_type: "string", name: "owner", value: "alice"}
        ],
        context_attrs: [
          %{data_type: "range", name: "year", value: %{max: 2030}}
        ]
      }

      new_policy = %{
        version: "2",
        id: "...",
        name: "alice's policy",
        privileges: %{
          subject: %{"id" => "alice"},
          object: %{"owner" => "alice"},
          context: %{"year" => %{"max" => 2030}},
          operations: ["create", "read", "update", "delete"],
        }
      }

      assert ^new_policy = Serialization.from_old_to_new(old_policy)

      assert ^old_policy = Serialization.from_new_to_old(new_policy)
    end
  end
end
