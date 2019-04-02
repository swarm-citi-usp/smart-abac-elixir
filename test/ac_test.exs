defmodule ACTest do
  use ExUnit.Case
  doctest AC
  alias AC.{PDP, Attr, Policy, Request}

  test "match single request attribute against policy attribute" do
    policy_attr = %Attr{data_type: "string", name: "Type", value: "Person"}
    assert PDP.match_attr(policy_attr.data_type, {"Type", "Person"}, policy_attr)
    refute PDP.match_attr(policy_attr.data_type, {"Id", "Person"}, policy_attr)
    refute PDP.match_attr(policy_attr.data_type, {"Type", "Camera"}, policy_attr)
  end

  test "match context against policy context" do
    day_time_attr = %Attr{data_type: "time_window", name: "DateTime", value: "* * 6-22 * * *"}
    refute PDP.match_attr(day_time_attr.data_type, {"DateTime", "0 0 5  1 1 2019"}, day_time_attr)
    assert PDP.match_attr(day_time_attr.data_type, {"DateTime", "0 0 6  1 1 2019"}, day_time_attr)
    assert PDP.match_attr(day_time_attr.data_type, {"DateTime", "0 0 7  1 1 2019"}, day_time_attr)
    assert PDP.match_attr(day_time_attr.data_type, {"DateTime", "0 0 21 1 1 2019"}, day_time_attr)
    assert PDP.match_attr(day_time_attr.data_type, {"DateTime", "0 0 22 1 1 2019"}, day_time_attr)
    refute PDP.match_attr(day_time_attr.data_type, {"DateTime", "0 0 23 1 1 2019"}, day_time_attr)
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

  describe "authorize a request" do
    setup [:policy_and_request]

    test "authorize a request", %{
      policy_family: policy_family,
      policy_person: policy_person,
      request: request
    } do
      refute PDP.authorize(request, [policy_family])
      assert PDP.authorize(request, [policy_person])
      assert PDP.authorize(request, [policy_person, policy_family])
    end

    test "authorize a request considering the context", %{
      policy_person: policy_person,
      request: request
    } do
      request =
        Map.put(request, :context_attrs, %{
          "DateTime" => "0 0 6  1 1 2019"
        })

      policy_person =
        Map.put(policy_person, :context_attrs, [
          %Attr{
            data_type: "time_window",
            name: "DateTime",
            value: "* * 6-22 * * *"
          }
        ])

      assert PDP.authorize(request, [policy_person])
    end
  end

  describe "hierarchical attributes" do
    setup [:policy_and_request]

    defmodule AttrHierarchyClientMock do
      def get_contained_attrs("SecurityAppliance") do
        ["SecurityCamera", "IntrusionAlarm"]
      end

      def get_contained_attrs("AdultFamilyMember") do
        ["Father", "Mother"]
      end

      def get_contained_attrs("Indoor") do
        ["Laboratory", "MeetingRoom", "Hall"]
      end

      def get_contained_attrs(_), do: []

      def get_attr_containers("SecurityCamera") do
        ["SecurityAppliance", "Appliance"]
      end

      def get_attr_containers("Father") do
        ["AdultFamilyMember", "FamilyMember", "Persona"]
      end

      def get_attr_containers(_), do: []
    end

    test "match contained request attribute against policy attribute" do
      policy_attr = %Attr{data_type: "string", name: "Type", value: "SecurityAppliance"}
      assert PDP.match_attr(policy_attr.data_type, {"Type", "SecurityAppliance"}, policy_attr)

      policy_attr = %Attr{data_type: "string", name: "Type", value: "SecurityAppliance"}

      assert PDP.match_attr(
               policy_attr.data_type,
               {"__containers__", ["SecurityAppliance"]},
               policy_attr
             )
    end

    test "authorize a request using attribute hierarchy / containment" do
      policy_family = %Policy{
        id: "...",
        name: "Adult Home Control",
        user_attrs: [
          %Attr{data_type: "string", name: "Role", value: "AdultFamilyMember"},
          %Attr{data_type: "range", name: "Age", value: %{min: 18}}
        ],
        operations: ["read"],
        object_attrs: [
          %Attr{data_type: "string", name: "Type", value: "SecurityAppliance"}
        ]
      }

      request = %Request{
        user_attrs: %{
          "Id" => "1atJsQno5yjJE7raHWSV4Py3b9BndatXGzbB88f7QYsZLhvHSG",
          "Role" => "Father",
          "Age" => 25
        },
        object_attrs: %{
          "Type" => "SecurityCamera",
          "Location" => "Kitchen"
        },
        operations: ["read"]
      }

      assert PDP.authorize(request, [policy_family])
    end

    test "expand user attributes" do
      user_attrs = %{
        "Id" => "1atJsQno5yjJE7raHWSV4Py3b9BndatXGzbB88f7QYsZLhvHSG",
        "Role" => "Father",
        "Age" => 25
      }

      container_user_attrs = AttrHierarchyClientMock.get_attr_containers("Father")
      user_attrs = Map.put(user_attrs, "__containers__", container_user_attrs)

      assert user_attrs == AC.Request.add_attr_containers(user_attrs)
    end

    test "attribute replace" do
      attrs = [
        %Attr{data_type: "string", name: "Type", value: "AdultFamilyMember"},
        %Attr{data_type: "string", name: "Location", value: "Indoor"},
        %Attr{data_type: "range", name: "Age", value: %{min: 18}}
      ]

      replaced_attrs =
        AC.replace_attr(
          attrs,
          %Attr{data_type: "string", name: "Type", value: "AdultFamilyMember"},
          %Attr{data_type: "string", name: "Type", value: "FamilyMember"}
        )

      assert length(replaced_attrs) == 3
      assert %Attr{data_type: "string", name: "Type", value: "FamilyMember"} in replaced_attrs

      refute %Attr{data_type: "string", name: "Type", value: "AdultFamilyMember"} in replaced_attrs
    end

    test "generate expanded flat policies based on attribute hierarchy / containment" do
      policy = %Policy{
        id: "...",
        name: "Adult Home Control",
        user_attrs: [
          %Attr{data_type: "string", name: "Type", value: "AdultFamilyMember"},
          %Attr{data_type: "string", name: "Location", value: "Indoor"},
          %Attr{data_type: "range", name: "Age", value: %{min: 18}}
        ],
        operations: ["read"],
        object_attrs: [
          %Attr{data_type: "string", name: "Type", value: "SecurityAppliance"},
          %Attr{data_type: "string", name: "Location", value: "Indoor"}
        ]
      }

      generated_policies = AC.Policy.generate_expanded_policies(policy)

      attribute_combinations =
        ["AdultFamilyMember", "Indoor", "SecurityAppliance", "Indoor"]
        |> Enum.flat_map(fn attr -> AttrHierarchyClientMock.get_contained_attrs(attr) end)

      # the length should be the number of combinations plus one original policy
      assert length(generated_policies) == length(attribute_combinations) + 1
    end
  end

  def policy_and_request(_) do
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

    request = %Request{
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

    {:ok, policy_family: policy_family, policy_person: policy_person, request: request}
  end
end
