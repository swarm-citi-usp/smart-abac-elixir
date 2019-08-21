# ABAC-them

This is a new Attribute-Based Access Control (ABAC) model.

It is named after the initial of its features:

- Typed: attributes have types
- Hierarchical: attributes can have hierarchies
- Enumerated: policies are created by enumerating accepted values
- Multi-Attribute: each policy container can have more than one attribute

## Installation

```
$ git clone git@gitlab.com:swarm-unit/abac-them.git
$ mix deps.get
$ mix test # run the tests to ensure everything is working
```

## Running

Use `iex -S mix` for running `ABACthem` application.

If you want to benefit from the [Hierarchy Service](), be sure to start it up as well: `cd priv/abac_them_hierarchy && python abac_them_hierarchy/service.py -g tests/example_home_policy.n3`

## Example

Let's consider some access control scenarios and try to model them using ABACthem:

1. Any security appliance can be accessed and modified by an adult family member.
2. Outdoor cameras are available for renting by any user whose reputation is at least 4, during daylight hours.
3. A specific camera can be read by a specific user, during five minutes of a specific day (this type of policy is created when a Swarm service is contracted, as permitted by policy \#2 and described in detail in \cite{biase2018swarm}).

To satisfy these scenarios, we create a corresponding `Policy`, add each to the `Store`, and evaluate them against a `Request`.

### Policy 1

```
alias ABACthem.{PDP, Attr, Policy, Request, Store}

%Policy{
  id: "0",
  user_attrs: [
    %Attr{data_type: "string", name: "swarm:Role", value: "swarm:AdultFamilyMember"}
  ],
  operations: ["read", "update"],
  object_attrs: [
    %Attr{data_type: "string", name: "swarm:Type", value: "swarm:SecurityAppliance"}
  ]
} |> Store.update()


request = %Request{
  user_attrs: %{
    "swarm:Role" => "swarm:Father"
  },
  object_attrs: %{
    "swarm:Type" => "swarm:SecurityCamera"
  },
  operations: ["read"]
}

ABACthem.authorize(request) # true
```

### Policy 2
```
%Policy{
  id: "1",
  user_attrs: [
    %Attr{data_type: "range", name: "swarm:Reputation", value: %{min: 4}}
  ],
  operations: ["buy"],
  object_attrs: [
    %Attr{data_type: "string", name: "swarm:Type", value: "swarm:SecurityCamera"},
    %Attr{data_type: "string", name: "swarm:Location", value: "swarm:Outdoor"}
  ],
  context_attrs: [
    %Attr{data_type: "time_interval", name: "swarm:DateTime", value: "* * 8-18 * * *"}
  ]
} |> Store.update()

request = %Request{
  user_attrs: %{
    "swarm:Id" => "swarm:r03...bh8",
    "swarm:Reputation" => 4.23
  },
  object_attrs: %{
    "swarm:Type" => "swarm:SecurityCamera",
    "swarm:Location" => "swarm:Sidewalk"
  },
  operations: ["buy"]
}

ABACthem.authorize(request) # true
```

### Policy 3
```
%Policy{
  id: "2",
  user_attrs: [
    %Attr{data_type: "string", name: "swarm:Id", value: "swarm:8a5...934"}
  ],
  operations: ["read"],
  object_attrs: [
    %Attr{data_type: "string", name: "swarm:Id", value: "swarm:e35...85a"},
    %Attr{data_type: "string", name: "swarm:Type", value: "swarm:SecurityCamera"}
  ],
  context_attrs: [
    # ADJUST the date and time below to test this!
    %Attr{data_type: "time_interval", name: "swarm:DateTime", value: "0-60 1-10 21 21 8 2019"}
  ]
} |> Store.update()

request = %Request{
  user_attrs: %{
    "swarm:Id" => "swarm:8a5...934",
  },
  object_attrs: %{
    "swarm:Id" => "swarm:e35...85a",
    "swarm:Type" => "swarm:SecurityCamera"
  },
  operations: ["read"]
} |> IO.inspect

ABACthem.authorize(request) # must be brue
```
