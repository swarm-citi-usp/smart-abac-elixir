[
  %ABACthem.Policy{
    id: "...",
    name: "Adult home control",
    user_attrs: [
      %ABACthem.Attr{data_type: "string", name: "Type", value: "s:AdultFamilyMember"}
    ],
    operations: ["all"],
    object_attrs: [
      %ABACthem.Attr{data_type: "string", name: "Type", value: "s:Appliance"}
    ]
  },
  %ABACthem.Policy{
    id: "...",
    name: "Children home control",
    user_attrs: [
      %ABACthem.Attr{data_type: "string", name: "Type", value: "s:Children"}
    ],
    operations: ["read", "update"],
    object_attrs: [
      %ABACthem.Attr{data_type: "string", name: "Type", value: "s:EntertainmentAppliance"}
    ]
  },
  %ABACthem.Policy{
    id: "...",
    name: "Emergency home access",
    user_attrs: [
      %ABACthem.Attr{data_type: "string", name: "Type", value: "s:Persona"},
      %ABACthem.Attr{data_type: "range", name: "Reputation", value: %{min: 4}}
    ],
    operations: ["read", "update"],
    object_attrs: [
      %ABACthem.Attr{data_type: "string", name: "Type", value: "s:HomeAppliance"}
    ],
    context_attrs: [
      %ABACthem.Attr{data_type: "string", name: "Situation", value: "s:Emergency"}
    ]
  }
]

# iex(20)> ABACthem.PDP.authorize(%ABACthem.Request{user_attrs: %{"Type" => "s:AdultFamilyMember"}, operations: ["read"], object_attrs: %{"Type" => "s:Door"}}, ABACthem._policies())
# true
# iex(21)> ABACthem.PDP.authorize(%ABACthem.Request{user_attrs: %{"Type" => "s:AdultFamilyMember"}, operations: ["read"], object_attrs: %{"Type" => "s:SecurityCamera"}}, ABACthem._policies())
# true
# iex(22)> ABACthem.PDP.authorize(%ABACthem.Request{user_attrs: %{"Type" => "s:FamilyMember"}, operations: ["read"], object_attrs: %{"Type" => "s:SecurityCamera"}}, ABACthem._policies())
# false
# iex(23)> ABACthem.PDP.authorize(%ABACthem.Request{user_attrs: %{"Type" => "s:Children"}, operations: ["read"], object_attrs: %{"Type" => "s:SecurityCamera"}}, ABACthem._policies())
# false
# iex(24)> ABACthem.PDP.authorize(%ABACthem.Request{user_attrs: %{"Type" => "s:Children"}, operations: ["read"], object_attrs: %{"Type" => "s:TV"}}, ABACthem._policies())
# true
# iex(25)> ABACthem.PDP.authorize(%ABACthem.Request{user_attrs: %{"Type" => "s:Persona", "Reputation" => 4.5}, operations: ["update"], object_attrs: %{"Type" => "s:Door"}, context_attrs: %{"Situation" => "s:Emergency"}}, ABACthem._policies())
# true
# iex(26)> ABACthem.PDP.authorize(%ABACthem.Request{user_attrs: %{"Type" => "s:Persona", "Reputation" => 2.5}, operations: ["update"], object_attrs: %{"Type" => "s:Door"}, context_attrs: %{"Situation" => "s:Emergency"}}, ABACthem._policies())
# false
