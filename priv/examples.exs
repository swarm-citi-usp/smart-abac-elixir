[
  %ABACthem.Policy{
    id: "#{System.unique_integer([:positive])}",
    name: "Adult home control",
    user_attrs: [
      %ABACthem.Attr{data_type: "string", name: "s:Type", value: "s:AdultFamilyMember"}
    ],
    operations: ["all"],
    object_attrs: [
      %ABACthem.Attr{data_type: "string", name: "s:Type", value: "s:Appliance"}
    ]
  },
  %ABACthem.Policy{
    id: "#{System.unique_integer([:positive])}",
    name: "Children home control",
    user_attrs: [
      %ABACthem.Attr{data_type: "string", name: "s:Type", value: "s:Children"}
    ],
    operations: ["read", "update"],
    object_attrs: [
      %ABACthem.Attr{data_type: "string", name: "s:Type", value: "s:EntertainmentAppliance"}
    ]
  },
  %ABACthem.Policy{
    id: "#{System.unique_integer([:positive])}",
    name: "Emergency home access",
    user_attrs: [
      %ABACthem.Attr{data_type: "string", name: "s:Type", value: "s:Persona"},
      %ABACthem.Attr{data_type: "range", name: "s:Reputation", value: %{min: 4}}
    ],
    operations: ["read", "update"],
    object_attrs: [
      %ABACthem.Attr{data_type: "string", name: "s:Type", value: "s:HomeAppliance"}
    ],
    context_attrs: [
      %ABACthem.Attr{data_type: "string", name: "s:Situation", value: "s:Emergency"}
    ]
  }
] |> Enum.each(&ABACthem.Store.update(&1))

# NOTE: these examples only work if the Hierachy Service is running on backgrond.

ABACthem.authorize(%ABACthem.Request{user_attrs: %{"s:Type" => "s:AdultFamilyMember"}, operations: ["read"], object_attrs: %{"s:Type" => "s:Door"}})
# true
ABACthem.authorize(%ABACthem.Request{user_attrs: %{"s:Type" => "s:AdultFamilyMember"}, operations: ["read"], object_attrs: %{"s:Type" => "s:SecurityCamera"}})
# true
ABACthem.authorize(%ABACthem.Request{user_attrs: %{"s:Type" => "s:FamilyMember"}, operations: ["read"], object_attrs: %{"s:Type" => "s:SecurityCamera"}})
# false
ABACthem.authorize(%ABACthem.Request{user_attrs: %{"s:Type" => "s:Children"}, operations: ["read"], object_attrs: %{"s:Type" => "s:SecurityCamera"}})
# false
ABACthem.authorize(%ABACthem.Request{user_attrs: %{"s:Type" => "s:Children"}, operations: ["read"], object_attrs: %{"s:Type" => "s:TV"}})
# true
ABACthem.authorize(%ABACthem.Request{user_attrs: %{"s:Type" => "s:Persona", "s:Reputation" => 4.5}, operations: ["update"], object_attrs: %{"s:Type" => "s:Door"}, context_attrs: %{"s:Situation" => "s:Emergency"}})
# true
ABACthem.authorize(%ABACthem.Request{user_attrs: %{"s:Type" => "s:Persona", "s:Reputation" => 2.5}, operations: ["update"], object_attrs: %{"s:Type" => "s:Door"}, context_attrs: %{"s:Situation" => "s:Emergency"}})
# false


# this one does not need hierarchy
ABACthem.PDP.authorize(%ABACthem.Request{user_attrs: %{"s:Type" => "s:AdultFamilyMember"}, operations: ["read"], object_attrs: %{"s:Type" => "s:HomeAppliance"}}, policies)
#true
