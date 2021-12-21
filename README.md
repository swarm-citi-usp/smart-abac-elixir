# SmartABAC

Elixir implementation of the SmartABAC access control model. [See our paper here](https://ieeexplore.ieee.org/abstract/document/9528856). A C version is [also available](https://github.com/swarm-citi-usp/smart-abac-c).

SmartABAC is a new attribute-based access control model that can be embedded in IoT devices with minimal overhead. It provides the following features:

- enumerated access policies: lightweight to evaluate
- typed attributes: increased expressiveness
- attribute hierarchies: simpler policy administration
- multi-attribute policies: easy conjunctive policies in enumerated models

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

# Example

Consider a smart-home use case with the following restriction: _any security camera can be accessed and modified by any adult family member_.

The following code creates an SmartABAC policy that represents this restriction, and runs some requests against it.

```elixir
# 1. create and store the policy in memory
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

# 2a. check authorization for a request that's expected to be allowed
%{
  "subject" => %{"age" => 25, "name" => "Alice"},
  "object" => %{"type" => "securityCamera"},
  "operations" => [%{"@type" => "read"}],
} |> SmartABAC.authorize()

# 2b. check authorization for a request that's expected to be denied (age < 18)
%{
  "subject" => %{"age" => 10, "name" => "Alice"},
  "object" => %{"type" => "securityCamera"},
  "operations" => [%{"@type" => "read"}],
} |> SmartABAC.authorize()
```

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

# Motivation

This model exists because existing models are either:

- Too complex, e.g.:
  - [XACML](http://docs.oasis-open.org/xacml/3.0/xacml-3.0-core-spec-os-en.html) uses XML and is too verbose
  - [HGABAC](https://link.springer.com/chapter/10.1007/978-3-319-17040-4_12) uses a concise logic language, but requires advanced parsers and can be NP-complete to audit
- Too restrictive, e.g.:
  - RBAC only supports roles
  - [EAP-ABACm,n](https://profsandhu.com/ics/2017%20Prosunjit%20Biswas.pdf) does not support types nor hierarchies
  - [Policy Machine](https://www.sciencedirect.com/science/article/pii/S1383762110000251) does not support types nor conjunctive policies

# Contributing

Download the repo, write code & tests, and send a PR.

# Citing
If you use this code in your research, please cite as follows:

```
@article{fedrecheski2021smartabac,
  title={SmartABAC: enabling constrained IoT devices to make complex policy-based access control decisions},
  author={Fedrecheski, Geovane and De Biase, Laisa CC and Calcina-Ccori, Pablo C and Lopes, Roseli D and Zuffo, Marcelo K},
  journal={IEEE Internet of Things Journal},
  year={2021},
  publisher={IEEE}
}
