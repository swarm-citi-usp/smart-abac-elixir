defmodule PDPTest do
  use ExUnit.Case
  import ABACthem.Factory
  alias ABACthem.{PDP}
  alias ABACthem.Types.Attr

  describe "verify authorizations" do
    test "authorize with regular policy" do
      {:ok, new_policy} = params_for(:policy) |> ABACthem.create_policy()
      {:ok, request} = params_for(:request) |> ABACthem.build_request()

      assert PDP.authorize(request, [new_policy])
      refute PDP.authorize(%{request | operations: ["teleport"]}, [new_policy])
    end

    test "authorize, policy with nested object" do
      {:ok, new_policy} =
        params_for(:policy)
        |> put_in([:privileges, :object], %{
          "type" => "camera",
          "geolocation" => %{"street" => "Rua Ceslau Marcelo Swartz", "number" => 214}
        })
        |> put_in([:privileges, :context], %{})
        |> ABACthem.create_policy()

      {:ok, request} =
        params_for(:request)
        |> put_in([:object], %{
          "type" => "camera",
          "geolocation" => %{"street" => "Rua Ceslau Marcelo Swartz", "number" => 214}
        })
        |> ABACthem.build_request()

      assert PDP.authorize(request, [new_policy])

      request = %{
        request
        | object: %{"owner" => "camera", "geolocation" => %{"street" => "Rua dos Bobos"}}
      }

      refute PDP.authorize(request, [new_policy])
    end
  end

  describe "verify attribute matchings" do
    test "match single request attribute against policy attribute" do
      policy_attr = %Attr{data_type: "string", name: "Type", value: "Person"}
      assert PDP.match_attr(policy_attr.data_type, {"Type", "Person"}, policy_attr)
      refute PDP.match_attr(policy_attr.data_type, {"Id", "Person"}, policy_attr)
      refute PDP.match_attr(policy_attr.data_type, {"Type", "Camera"}, policy_attr)
    end

    test "match numerical ranges" do
      assert PDP.match_range(25, %{min: 18, max: 30})
      assert PDP.match_range(25, %{min: 18})
      assert PDP.match_range(25, %{max: 30})
      refute PDP.match_range(25, %{})
      refute PDP.match_range(17, %{min: 18, max: 30})
      refute PDP.match_range(31, %{min: 18, max: 30})
    end

    test "match list of request attributes against list of policy attributes" do
      request_attrs = %{
        "Id" => "1atJsQno5yjJE7raHWSV4Py3b9BndatXGzbB88f7QYsZLhvHSG",
        "Type" => "Person",
        "Role" => "FamilyMember",
        "Age" => 25
      }

      policy_attrs = %{"Type" => "Person", "Role" => "FamilyMember"}

      assert PDP.match_attrs(request_attrs, policy_attrs)
      refute PDP.match_attrs(Map.delete(request_attrs, "Type"), policy_attrs)
      refute PDP.match_attrs(Map.delete(request_attrs, "Role"), policy_attrs)
      assert PDP.match_attrs(Map.delete(request_attrs, "Id"), policy_attrs)
    end

    test "match request operations against policy operations" do
      refute PDP.match_operations([], ["read"])
      refute PDP.match_operations(["read"], [])

      assert PDP.match_operations(["read"], ["read", "update", "delete"])
      assert PDP.match_operations(["read", "update"], ["read", "update", "delete"])
      assert PDP.match_operations(["read", "update", "delete"], ["read", "update", "delete"])

      refute PDP.match_operations(["create", "read", "update", "delete"], [
               "read",
               "update",
               "delete"
             ])
    end

    test "attribute name must be string, not atom" do
      assert PDP.match_attr(
               "string",
               {"swarm:Type", "swarm:SecurityCamera"},
               %{data_type: "string", name: "swarm:Type", value: "swarm:SecurityCamera"}
             )

      refute PDP.match_attr(
               "string",
               {:"swarm:Type", "swarm:SecurityCamera"},
               %{data_type: "string", name: "swarm:Type", value: "swarm:SecurityCamera"}
             )
    end
  end
end
