# ABAC-them

This is a new access control model.

It is named after the initial of its features:

- Typed: attributes have types
- Hierarchical: attributes can have hierarchies
- Enumeration: policies are created by enumerating accepted values
- Multiple Attributes: each policy container can have more than one attribute

## Installation

```
$ git clone git@gitlab.com:swarm-unit/fepama.git
$ mix deps.get
$ mix test # run the tests to ensure everything is working
```

## Running

Use `iex -S mix` for running `ABACthem` application.

If you want to benefit from the [Hierarchy Service](), be sure to start it up as well.

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
    %Attr{data_type: "string", name: "s:Role", value: "s:AdultFamilyMember"}
  ],
  operations: ["read", "update"],
  object_attrs: [
    %Attr{data_type: "string", name: "s:Type", value: "s:SecurityAppliance"}
  ]
} |> Store.update()


request = %Request{
  user_attrs: %{
    "s:Role" => "s:Father"
  },
  object_attrs: %{
    "s:Type" => "s:SecurityCamera"
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
    %Attr{data_type: "range", name: "s:Reputation", value: %{min: 4}}
  ],
  operations: ["buy"],
  object_attrs: [
    %Attr{data_type: "string", name: "s:Type", value: "s:SecurityCamera"},
    %Attr{data_type: "string", name: "s:Location", value: "s:Outdoor"}
  ],
#  context_attrs: [
#    %Attr{data_type: "time_interval", name: "s:DateTime", value: "* * 8-18 * * *"}
#  ]
} |> Store.update()

request = %Request{
  user_attrs: %{
    "s:Id" => "s:r03...bh8",
    "s:Reputation" => 4.23
  },
  object_attrs: %{
    "s:Type" => "s:SecurityCamera",
    "s:Location" => "s:Sidewalk"
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
    %Attr{data_type: "string", name: "s:Id", value: "s:8a5...934"}
  ],
  operations: ["read"],
  object_attrs: [
    %Attr{data_type: "string", name: "s:Id", value: "s:e35...85a"},
    %Attr{data_type: "string", name: "s:Type", value: "s:SecurityCamera"}
  ],
#  context_attrs: [
#    %Attr{data_type: "time_interval", name: "s:DateTime", value: "10 20-25 12 6 6 2019"}
#  ]
} |> Store.update()

request = %Request{
  user_attrs: %{
    "s:Id" => "s:8a5...934",
  },
  object_attrs: %{
    "s:Id" => "s:e35...85a",
    "s:Type" => "s:SecurityCamera"
  },
  operations: ["read"]
} |> IO.inspect

ABACthem.authorize(request) # must be brue
```
