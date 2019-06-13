defmodule ABACthem.StoreTest do
  use ExUnit.Case
  doctest ABACthem
  alias ABACthem.{PDP, Attr, Policy, Request, Store}

  test "store and retrieve policy, and evaluate against request (no hierarchy)" do
    %Policy{
      id: "1",
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
    |> Store.update()

    %Policy{
      id: "2",
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
    |> Store.update()

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

    assert PDP.authorize(request, Store.all())
  end
end
