# ABAC-them

This repo implements a novel Attribute-Based Access Control (ABAC) model that is intended to be run within IoT devices to protect their interactions.

# Example

Consider a smart-home use case, with the restriction _any security camera can be accessed and modified by any adult family member_.

The following code section creates an ABAC-them policy that represents this restriction, and runs some requests against it.

```elixir
%{
  "id" => "1234",
  "name" => "security access for adults",
  "privileges" => %{
    "subject" => %{"age" => %{"min" => 18}},
    "object" => %{"type" => "securityCamera"},
    "context" => %{},
    "operations" => ["create", "read", "update"],
  }
} |> ABACthem.create_policy()

# to test this policy, we create a request and try to authorize it

# this should return true
%{
  "subject" => %{"age" => 25, "name" => "Alice"},
  "object" => %{"type" => "securityCamera"},
  "operations" => ["read"],
} |> ABACthem.authorize()

# and this should return false
%{
  "subject" => %{"age" => 10, "name" => "Alice"},
  "object" => %{"type" => "securityCamera"},
  "operations" => ["read"],
} |> ABACthem.authorize()
```

# Installation

Add to your `mix.exs` file:

```
  defp deps do
    [
      # ...
      {:abac_them, "git@github.com:swarm-citi-usp/abac-them-elixir.git"}
    ]
  end
```

# Details

## The `them` acronym
The model is named after its main features:

- Typed: attributes have types
- Hierarchical: attribute values can have hierarchies
- Enumerated: policies are created by enumerating accepted values
- Multi-Attribute: each policy container can have more than one attribute

## Motivation

This model exists because existing models are either:

- Too complex, e.g.:
  - XACML uses XML and is bloated
  - HGABAC uses a concise logic language, but requires advanced parsers and can be NP-complete to review
- Too restrictive, e.g.:
  - RBAC only supports roles
  - EAP-ABACm,n does not support types nor hierarchies
  - Policy Machine does not support types nor conjunctive policies

# Contributing

1. Download the repo and run the tests:

```
$ git clone git@gitlab.com:swarm-unit/abac-them.git
$ mix deps.get
$ mix test # run the tests to ensure everything is working
```

2. Modify the code, **write tests** covering your change, and send a pull request.
