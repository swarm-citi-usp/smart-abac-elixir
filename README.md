# SmartABAC

This repo implements a novel Attribute-Based Access Control (ABAC) model that is intended to be run within IoT devices to protect their interactions.

# Example

Consider a smart-home use case with the following restriction: _any security camera can be accessed and modified by any adult family member_.

The following code section creates an SmartABAC policy that represents this restriction, and runs some requests against it.

```elixir
%{
  "id" => "1234",
  "name" => "security access for adults",
  "permissions" => %{
    "subject" => %{"age" => %{"min" => 18}},
    "object" => %{"type" => "securityCamera"},
    "context" => %{},
    "operations" => [%{"@type" => "create"}, %{"@type" => "read"}, %{"@type" => "update"}],
  }
} |> SmartABAC.create_policy()

# to test this policy, we create a request and try to authorize it

# this should return true
%{
  "subject" => %{"age" => 25, "name" => "Alice"},
  "object" => %{"type" => "securityCamera"},
  "operations" => [%{"@type" => "read"}],
} |> SmartABAC.authorize()

# and this should return false
%{
  "subject" => %{"age" => 10, "name" => "Alice"},
  "object" => %{"type" => "securityCamera"},
  "operations" => [%{"@type" => "read"}],
} |> SmartABAC.authorize()
```

# Installation

Add to your `mix.exs` file:

```
  defp deps do
    [
      # ...
      {:smart_abac, "git@github.com:swarm-citi-usp/smart-abac-elixir.git"}
    ]
  end
```

# Details

## Serialization

Currenly JSON and CBOR are supported.

JSON example:

```elixir
"""
{
  "id": "1234",
  "version": "2.0",
  "name": "security access for adults",
  "permissions": {
    "subject": {"age": {"min": 18}},
    "object": {"type": "securityCamera"},
    "context": {},
    "operations": [{"@type": "create"}, {"@type": "read"}, {"@type": "update"}]
  }
}
""" |> SmartABAC.Serialization.from_json()
```

CBOR example:
```elixir
"A36269646431323334646E616D65781A73656375726974792061636365737320" <>
"666F72206164756C74736B7065726D697373696F6E73A467636F6E74657874A0" <>
"666F626A656374A164747970656E736563757269747943616D6572616A6F7065" <>
"726174696F6E7383A165407479706566637265617465A1654074797065647265" <>
"6164A165407479706566757064617465677375626A656374A163616765A1636D" <>
"696E12" |> SmartABAC.Serialization.from_cbor(:hex)
```

## Motivation

This model exists because existing models are either:

- Too complex, e.g.:
  - [XACML](http://docs.oasis-open.org/xacml/3.0/xacml-3.0-core-spec-os-en.html) uses XML and is too verbose
  - [HGABAC](https://link.springer.com/chapter/10.1007/978-3-319-17040-4_12) uses a concise logic language, but requires advanced parsers and can be NP-complete to audit
- Too restrictive, e.g.:
  - RBAC only supports roles
  - [EAP-ABACm,n](https://profsandhu.com/ics/2017%20Prosunjit%20Biswas.pdf) does not support types nor hierarchies
  - [Policy Machine](https://www.sciencedirect.com/science/article/pii/S1383762110000251) does not support types nor conjunctive policies

# Contributing

1. Download the repo and run the tests:

```
$ git clone git@github.com:swarm-citi-usp/smart-abac-elixir.git
$ mix deps.get
$ mix test # run the tests to ensure everything is working
```

2. Modify the code, **write tests** covering your change, and send a pull request.
