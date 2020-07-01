# ABAC-them

This is a new Attribute-Based Access Control (ABAC) model.

It is named after the initial of its features:

- Typed: attributes have types
- Hierarchical: attributes can have hierarchies
- Enumerated: policies are created by enumerating accepted values
- Multi-Attribute: each policy container can have more than one attribute

## Installation

Add to `mix.exs` file:

```
  defp deps do
    [
      # ...
      {:abac_them, "git@github.com:swarm-citi-usp/abac-them-elixir.git"}
    ]
  end
```

# Example

Consider a smart-home use case, with the restriction _any security appliance can be accessed and modified by any adult family member_.

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

# Contributing

1. Download the repo and run the tests:

```
$ git clone git@gitlab.com:swarm-unit/abac-them.git
$ mix deps.get
$ mix test # run the tests to ensure everything is working
```

2. Modify the code, **write tests** covering your change, and send a pull request.
