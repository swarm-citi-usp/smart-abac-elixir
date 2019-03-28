defmodule AC do
  @moduledoc """
  Documentation for AC.
  """

  def _policies do
    [
      %AC.Policy{
        id: "...",
        name: "Adult home control",
        user_attrs: [
          %AC.Attr{data_type: "string", name: "Type", value: "s:AdultFamilyMember"}
        ],
        operations: ["all"],
        object_attrs: [
          %AC.Attr{data_type: "string", name: "Type", value: "s:Appliance"}
        ]
      },
      %AC.Policy{
        id: "...",
        name: "Children home control",
        user_attrs: [
          %AC.Attr{data_type: "string", name: "Type", value: "s:Children"}
        ],
        operations: ["read", "update"],
        object_attrs: [
          %AC.Attr{data_type: "string", name: "Type", value: "s:EntertainmentAppliance"}
        ]
      },
      %AC.Policy{
        id: "...",
        name: "Emergency home access",
        user_attrs: [
          %AC.Attr{data_type: "string", name: "Type", value: "s:Persona"},
          %AC.Attr{data_type: "range", name: "Reputation", value: %{min: 4}}
        ],
        operations: ["read", "update"],
        object_attrs: [
          %AC.Attr{data_type: "string", name: "Type", value: "s:HomeAppliance"}
        ],
        context_attrs: [
          %AC.Attr{data_type: "string", name: "Situation", value: "s:Emergency"}
        ]
      }
    ]

    # iex(20)> AC.PDP.authorize(%AC.Request{user_attrs: %{"Type" => "s:AdultFamilyMember"}, operations: ["read"], object_attrs: %{"Type" => "s:Door"}}, AC._policies())
    # true
    # iex(21)> AC.PDP.authorize(%AC.Request{user_attrs: %{"Type" => "s:AdultFamilyMember"}, operations: ["read"], object_attrs: %{"Type" => "s:SecurityCamera"}}, AC._policies())
    # true
    # iex(22)> AC.PDP.authorize(%AC.Request{user_attrs: %{"Type" => "s:FamilyMember"}, operations: ["read"], object_attrs: %{"Type" => "s:SecurityCamera"}}, AC._policies())
    # false
    # iex(23)> AC.PDP.authorize(%AC.Request{user_attrs: %{"Type" => "s:Children"}, operations: ["read"], object_attrs: %{"Type" => "s:SecurityCamera"}}, AC._policies())
    # false
    # iex(24)> AC.PDP.authorize(%AC.Request{user_attrs: %{"Type" => "s:Children"}, operations: ["read"], object_attrs: %{"Type" => "s:TV"}}, AC._policies())
    # true
    # iex(25)> AC.PDP.authorize(%AC.Request{user_attrs: %{"Type" => "s:Persona", "Reputation" => 4.5}, operations: ["update"], object_attrs: %{"Type" => "s:Door"}, context_attrs: %{"Situation" => "s:Emergency"}}, AC._policies())
    # true
    # iex(26)> AC.PDP.authorize(%AC.Request{user_attrs: %{"Type" => "s:Persona", "Reputation" => 2.5}, operations: ["update"], object_attrs: %{"Type" => "s:Door"}, context_attrs: %{"Situation" => "s:Emergency"}}, AC._policies())
    # false
  end
end
