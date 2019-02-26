defmodule ACTest do
  use ExUnit.Case
  doctest AC
  alias AC.{PDP, Attr, Policy}

  test "match single request attribute against policy attribute" do
    policy_attr = %Attr{data_type: "string", name: "Type", value: "Person"}
    assert PDP.match_attr({"Type", "Person"}, policy_attr)
    refute PDP.match_attr({"Id", "Person"}, policy_attr)
    refute PDP.match_attr({"Type", "Camera"}, policy_attr)
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

    policy_attrs = [
      %Attr{data_type: "string", name: "Type", value: "Person"},
      %Attr{data_type: "string", name: "Role", value: "FamilyMember"}
    ]

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

  test "authorize a request" do
    policy_family = %Policy{
      id: "...",
      name: "Adult Home Control",
      user_attrs: [
        %Attr{data_type: "string", name: "Type", value: "Person"},
        %Attr{data_type: "string", name: "Role", value: "FamilyMember"},
        %Attr{data_type: "range", name: "Age", value: %{min: 18}}
      ],
      operations: ["all"],
      object_attrs: [
        %Attr{data_type: "string", name: "Type", value: "AirConditioner"}
      ]
    }

    policy_person = %Policy{
      id: "...",
      name: "Adult Home Control",
      user_attrs: [
        %Attr{data_type: "string", name: "Type", value: "Person"},
        %Attr{data_type: "range", name: "Age", value: %{min: 18}}
      ],
      operations: ["read"],
      object_attrs: [
        %Attr{data_type: "string", name: "Type", value: "AirConditioner"}
      ]
    }

    request = %{
      user_attrs: %{
        "Id" => "1atJsQno5yjJE7raHWSV4Py3b9BndatXGzbB88f7QYsZLhvHSG",
        "Type" => "Person",
        "Age" => 25
      },
      object_attrs: %{
        "Type" => "AirConditioner",
        "Location" => "Kitchen"
      },
      operations: ["read"]
    }

    refute PDP.authorize(request, [policy_family])
    assert PDP.authorize(request, [policy_person])
    assert PDP.authorize(request, [policy_person, policy_family])
  end
end
