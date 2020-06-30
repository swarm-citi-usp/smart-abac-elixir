defmodule NewSerializationTest do
  use ExUnit.Case
  doctest ABACthem
  alias ABACthem.{Serialization, PDPv2}

  describe "authorizations" do
    test "authorize with regular policy" do
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
      request = %{
        subject: %{"id" => "alice"},
        object: %{"owner" => "alice"},
        context: %{"year" => 2020},
        operations: ["create"],
      }

      assert PDPv2.authorize(request, [new_policy])
      refute PDPv2.authorize(%{request | operations: ["teleport"]}, [new_policy])
    end

    test "authorize, policy with nested object" do
      new_policy = %{
        version: "2",
        id: "...",
        name: "alice's policy",
        privileges: %{
          subject: %{"id" => "alice"},
          object: %{"type" => "camera", "geolocation" =>
            %{"street" => "Rua Ceslau Marcelo Swartz", "number" => 214}},
          context: %{},
          operations: ["create", "read", "update", "delete"],
        }
      }
      request = %{
        subject: %{"id" => "alice"},
        object: %{"type" => "camera", "geolocation" =>
          %{"street" => "Rua Ceslau Marcelo Swartz", "number" => 214}},
        context: %{},
        operations: ["create"],
      }

      assert PDPv2.authorize(request, [new_policy])

      request = %{request | object: %{"owner" => "camera", "geolocation" => %{"street" => "Rua dos Bobos"}}}
      refute PDPv2.authorize(request, [new_policy])
    end
  end

  # to-do: deprecate?
  describe "conversion tests" do
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
end
