[
  %ABACthem.Policy{
    id: "#{System.unique_integer([:positive])}",
    name: "Adult home control",
    user_attrs: [
      %ABACthem.Attr{data_type: "string", name: "swarm:Type", value: "swarm:AdultFamilyMember"}
    ],
    operations: ["all"],
    object_attrs: [
      %ABACthem.Attr{data_type: "string", name: "swarm:Type", value: "swarm:Appliance"}
    ]
  },
  %ABACthem.Policy{
    id: "#{System.unique_integer([:positive])}",
    name: "Children home control",
    user_attrs: [
      %ABACthem.Attr{data_type: "string", name: "swarm:Type", value: "swarm:Children"}
    ],
    operations: ["read", "update"],
    object_attrs: [
      %ABACthem.Attr{data_type: "string", name: "swarm:Type", value: "swarm:EntertainmentAppliance"}
    ]
  },
  %ABACthem.Policy{
    id: "#{System.unique_integer([:positive])}",
    name: "Emergency home access",
    user_attrs: [
      %ABACthem.Attr{data_type: "string", name: "swarm:Type", value: "swarm:Persona"},
      %ABACthem.Attr{data_type: "range", name: "swarm:Reputation", value: %{min: 4}}
    ],
    operations: ["read", "update"],
    object_attrs: [
      %ABACthem.Attr{data_type: "string", name: "swarm:Type", value: "swarm:HomeAppliance"}
    ],
    context_attrs: [
      %ABACthem.Attr{data_type: "string", name: "swarm:Situation", value: "swarm:Emergency"}
    ]
  }
] |> Enum.each(&ABACthem.Store.update(&1))

# NOTE: these examples only work if the Hierachy Service is running on backgrond.

ABACthem.authorize(%ABACthem.Request{user_attrs: %{"swarm:Type" => "swarm:AdultFamilyMember"}, operations: ["read"], object_attrs: %{"swarm:Type" => "swarm:Door"}})
# true
ABACthem.authorize(%ABACthem.Request{user_attrs: %{"swarm:Type" => "swarm:AdultFamilyMember"}, operations: ["read"], object_attrs: %{"swarm:Type" => "swarm:SecurityCamera"}})
# true
ABACthem.authorize(%ABACthem.Request{user_attrs: %{"swarm:Type" => "swarm:FamilyMember"}, operations: ["read"], object_attrs: %{"swarm:Type" => "swarm:SecurityCamera"}})
# false
ABACthem.authorize(%ABACthem.Request{user_attrs: %{"swarm:Type" => "swarm:Children"}, operations: ["read"], object_attrs: %{"swarm:Type" => "swarm:SecurityCamera"}})
# false
ABACthem.authorize(%ABACthem.Request{user_attrs: %{"swarm:Type" => "swarm:Children"}, operations: ["read"], object_attrs: %{"swarm:Type" => "swarm:TV"}})
# true
ABACthem.authorize(%ABACthem.Request{user_attrs: %{"swarm:Type" => "swarm:Persona", "swarm:Reputation" => 4.5}, operations: ["update"], object_attrs: %{"swarm:Type" => "swarm:Door"}, context_attrs: %{"swarm:Situation" => "swarm:Emergency"}})
# true
ABACthem.authorize(%ABACthem.Request{user_attrs: %{"swarm:Type" => "swarm:Persona", "swarm:Reputation" => 2.5}, operations: ["update"], object_attrs: %{"swarm:Type" => "swarm:Door"}, context_attrs: %{"swarm:Situation" => "swarm:Emergency"}})
# false


# this one does not need hierarchy
ABACthem.PDP.authorize(%ABACthem.Request{user_attrs: %{"swarm:Type" => "swarm:AdultFamilyMember"}, operations: ["read"], object_attrs: %{"swarm:Type" => "swarm:HomeAppliance"}}, policies)
#true
