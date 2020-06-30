defmodule NewSerializationTest do
  use ExUnit.Case
  doctest ABACthem
  alias ABACthem.{Serialization}

  Application.put_env(:abac_them, :hierarchy_client, ABACthemTest.AttrHierarchyClientMock)

  test "convert" do
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

    assert ^new_policy = Serialization.from_old_to_new(old_policy)

    assert ^old_policy = Serialization.from_new_to_old(new_policy)
  end
end
