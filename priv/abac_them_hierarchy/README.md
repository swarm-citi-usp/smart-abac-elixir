# ABAC-them hierarchy


Run the service with:

```
python abac_them_hierarchy/service.py -g tests/example_home_policy.n3
```

And then expand attributes with:

```
http -v POST :4010/expansions name='swarm:Role' value='swarm:Father'
```

The expected response is:

```
[
  "swarm:Father",
  "swarm:AdultFamilyMember",
  "swarm:FamilyMember",
  "swarm:Persona"
]
```
