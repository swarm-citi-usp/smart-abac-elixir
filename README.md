# AC (FEPAMA)

This is a new access control PDP experiment.

It is named after the initial of its features:

- Flat: policies are not hierarchical
- EAP: enumeration is used to express policies
- PDP: this implements a Policy Decision Point, i.e., a function that, given a request and a list of policies, computes whether or not the policies allow that request
- ABAC: policies are based on users, objects, and context attributes
- Multiple Attributes: each policy container can have more than one attribute (for example, the policy machine is single-attribute)

## Installation

```
$ git clone git@gitlab.com:swarm-unit/fepama.git
$ mix deps.get
$ mix test # run the tests to ensure everything is working
```
