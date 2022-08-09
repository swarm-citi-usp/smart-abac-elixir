# Copyright (C) 2022 Geovane Fedrecheski <geonnave@gmail.com>
#               2022 Universidade de São Paulo
#               2022 LSI-TEC
#
# This file is part of the SwarmOS project, and it is subject to
# the terms and conditions of the GNU Lesser General Public License v2.1.
# See the file LICENSE in the top level directory for more details.

defmodule PDPTest do
  use ExUnit.Case
  import SmartABAC.Factory
  alias SmartABAC.{PDP}
  alias SmartABAC.Types.Attr

  describe "verify authorizations" do
    test "list authorized policies" do
      {:ok, new_policy} = params_for(:policy) |> SmartABAC.create_policy()
      {:ok, request} = params_for(:request) |> SmartABAC.build_request()

      authz_policies = PDP.list_authorized_policies(request, [new_policy])
      assert [_new_policy] = authz_policies
    end

    test "authorize with regular policy" do
      {:ok, new_policy} = params_for(:policy) |> SmartABAC.create_policy()
      {:ok, request} = params_for(:request) |> SmartABAC.build_request()

      assert PDP.authorize(request, [new_policy])
      refute PDP.authorize(%{request | operations: [%{"@type" => "teleport"}]}, [new_policy])
    end

    test "authorize, policy with nested object" do
      {:ok, new_policy} =
        params_for(:policy)
        |> put_in([:permissions, :object], %{
          "type" => "camera",
          "geolocation" => %{"street" => "Rua Ceslau Marcelo Swartz", "number" => 214}
        })
        |> put_in([:permissions, :context], %{})
        |> SmartABAC.create_policy()

      {:ok, request} =
        params_for(:request)
        |> put_in([:object], %{
          "type" => "camera",
          "geolocation" => %{"street" => "Rua Ceslau Marcelo Swartz", "number" => 214}
        })
        |> SmartABAC.build_request()

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

    test "match request operations against policy operations special cases" do
      refute PDP.match_operations([], [%{"@type" => "read"}])
      refute PDP.match_operations([%{"@type" => "read"}], [])
    end

    test "match request operations against policy operations" do
      assert PDP.match_operations([%{"@type" => "read"}], [%{"@type" => "read"}])

      assert PDP.match_operations([%{"@type" => "read"}], [
               %{"@type" => "read"},
               %{"@type" => "update"},
               %{"@type" => "delete"}
             ])

      assert PDP.match_operations([%{"@type" => "read"}, %{"@type" => "update"}], [
               %{"@type" => "read"},
               %{"@type" => "update"},
               %{"@type" => "delete"}
             ])

      assert PDP.match_operations(
               [%{"@type" => "read"}, %{"@type" => "update"}, %{"@type" => "delete"}],
               [%{"@type" => "read"}, %{"@type" => "update"}, %{"@type" => "delete"}]
             )

      refute PDP.match_operations(
               [
                 %{"@type" => "create"},
                 %{"@type" => "read"},
                 %{"@type" => "update"},
                 %{"@type" => "delete"}
               ],
               [
                 %{"@type" => "read"},
                 %{"@type" => "update"},
                 %{"@type" => "delete"}
               ]
             )
    end

    test "match request operations with entry" do
      assert PDP.match_operations([%{"@type" => "read", "entry" => "/temperature"}], [
               %{"@type" => "read", "entry" => "/temperature"}
             ])

      # request: read anything; policy: read temperature. result: unauthorized
      refute PDP.match_operations([%{"@type" => "read"}], [
               %{"@type" => "read", "entry" => "/temperature"}
             ])

      # request: read temperature; policy: read anything. result: authorized
      assert PDP.match_operations([%{"@type" => "read", "entry" => "/temperature"}], [
               %{"@type" => "read"}
             ])

      refute PDP.match_operations([%{"@type" => "read", "entry" => "/humidity"}], [
               %{"@type" => "read", "entry" => "/temperature"}
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
