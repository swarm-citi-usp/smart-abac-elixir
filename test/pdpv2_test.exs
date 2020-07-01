defmodule PDPv2Test do
  use ExUnit.Case
  import ABACthem.Factory
  alias ABACthem.{Formats, PDPv2, Attr}

  describe "verify authorizations" do
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

  describe "verify attribute matchings" do
    test "match single request attribute against policy attribute" do
      policy_attr = %Attr{data_type: "string", name: "Type", value: "Person"}
      assert PDPv2.match_attr(policy_attr.data_type, {"Type", "Person"}, policy_attr)
      refute PDPv2.match_attr(policy_attr.data_type, {"Id", "Person"}, policy_attr)
      refute PDPv2.match_attr(policy_attr.data_type, {"Type", "Camera"}, policy_attr)
    end

    test "match numerical ranges" do
      assert PDPv2.match_range(25, %{min: 18, max: 30})
      assert PDPv2.match_range(25, %{min: 18})
      assert PDPv2.match_range(25, %{max: 30})
      refute PDPv2.match_range(25, %{})
      refute PDPv2.match_range(17, %{min: 18, max: 30})
      refute PDPv2.match_range(31, %{min: 18, max: 30})
    end

    test "match list of request attributes against list of policy attributes" do
      request_attrs = %{
        "Id" => "1atJsQno5yjJE7raHWSV4Py3b9BndatXGzbB88f7QYsZLhvHSG",
        "Type" => "Person",
        "Role" => "FamilyMember",
        "Age" => 25
      }

      policy_attrs = %{"Type" => "Person", "Role" => "FamilyMember"}

      assert PDPv2.match_attrs(request_attrs, policy_attrs)
      refute PDPv2.match_attrs(Map.delete(request_attrs, "Type"), policy_attrs)
      refute PDPv2.match_attrs(Map.delete(request_attrs, "Role"), policy_attrs)
      assert PDPv2.match_attrs(Map.delete(request_attrs, "Id"), policy_attrs)
    end

    test "match request operations against policy operations" do
      refute PDPv2.match_operations([], ["read"])
      refute PDPv2.match_operations(["read"], [])

      assert PDPv2.match_operations(["read"], ["read", "update", "delete"])
      assert PDPv2.match_operations(["read", "update"], ["read", "update", "delete"])
      assert PDPv2.match_operations(["read", "update", "delete"], ["read", "update", "delete"])

      refute PDPv2.match_operations(["create", "read", "update", "delete"], [
               "read",
               "update",
               "delete"
             ])
    end

    test "attribute name must be string, not atom" do
      assert PDPv2.match_attr("string",
        {"swarm:Type", "swarm:SecurityCamera"},
        %{data_type: "string", name: "swarm:Type", value: "swarm:SecurityCamera"})

      refute PDPv2.match_attr("string",
        {:"swarm:Type", "swarm:SecurityCamera"},
        %{data_type: "string", name: "swarm:Type", value: "swarm:SecurityCamera"})
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

      assert ^new_policy = Formats.from_old_to_new(old_policy)

      assert ^old_policy = Formats.from_new_to_old(new_policy)
    end
  end
end
