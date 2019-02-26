defmodule ACTest do
  use ExUnit.Case
  doctest AC

  test "authorize a request" do
    policies = [
      %AC.Policy{
        id: "...",
        name: "Adult Home Control",
        user_attrs: [
          %AC.Attr{data_type: "string", name: "Type", value: "Person"},
          %AC.Attr{data_type: "string", name: "Role", value: "FamilyMember"},
          %AC.Attr{data_type: "range", name: "Age", value: %{min: 18}}
        ],
        operations: ["all"],
        object_attrs: [
          %AC.Attr{data_type: "string", name: "Type", value: "AirConditioner"}
        ]
      },
      %AC.Policy{
        id: "...",
        name: "Human Home Control",
        user_attrs: [
          %AC.Attr{data_type: "string", name: "Type", value: "Person"}
        ],
        operations: ["read"],
        object_attrs: [
          %AC.Attr{data_type: "string", name: "Type", value: "AirConditioner"}
        ]
      }
    ]

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

    refute AC.PDP.authorize(request)
  end

  test "match single request attribute against policy attribute" do
    policy_attr = %AC.Attr{data_type: "string", name: "Type", value: "Person"}
    assert AC.PDP.match_attr({"Type", "Person"}, policy_attr)
    refute AC.PDP.match_attr({"Id", "Person"}, policy_attr)
    refute AC.PDP.match_attr({"Type", "Camera"}, policy_attr)
  end

  test "match list of request attributes against list of policy attributes" do
    request_attrs = %{
      "Id" => "1atJsQno5yjJE7raHWSV4Py3b9BndatXGzbB88f7QYsZLhvHSG",
      "Type" => "Person",
      "Role" => "FamilyMember",
      "Age" => 25
    }

    policy_attrs = [
      %AC.Attr{data_type: "string", name: "Type", value: "Person"},
      %AC.Attr{data_type: "string", name: "Role", value: "FamilyMember"}
    ]

    assert AC.PDP.match_attrs(request_attrs, policy_attrs)
    refute AC.PDP.match_attrs(Map.delete(request_attrs, "Type"), policy_attrs)
    refute AC.PDP.match_attrs(Map.delete(request_attrs, "Role"), policy_attrs)
    assert AC.PDP.match_attrs(Map.delete(request_attrs, "Id"), policy_attrs)
  end
end
