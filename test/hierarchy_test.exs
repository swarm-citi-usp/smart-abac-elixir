defmodule HierarchyTest do
  use ExUnit.Case
  alias ABACthem.{Hierarchy}

  test "expand attrs" do
    assert ["swarm:Father"] == Hierarchy.expand_attr("swarm:Father")

    assert ["swarm:FamilyMember", "swarm:Father", "swarm:Mother", "swarm:AdultFamilyMember"] ==
             Hierarchy.expand_attr("swarm:FamilyMember")
  end

  test "run bfs" do
    graph = %{
      "c" => ["a", "b"],
      "d" => ["c", "e"],
      "e" => ["f"],
      "g" => ["e"]
    }

    assert ["f", "e"] = Hierarchy.bfs(graph, ["g"], [])
    assert ["f", "b", "a", "e", "c"] = Hierarchy.bfs(graph, ["d"], [])
    assert [] = Hierarchy.bfs(graph, ["a"], [])
    assert ["b", "a"] = Hierarchy.bfs(graph, ["c"], [])
  end

  test "parse graph from file" do
    graph_str = Hierarchy.open("abac_them_hierarchy/tests/example_home_policy.n3")

    graph =
      Hierarchy.parse(graph_str)
      |> Hierarchy.to_adjacency_list()

    assert graph["swarm:Acquaintance"] == ["swarm:Friend"]
  end

  test "parse graph inline" do
    graph_str = """
    swarm:Children
    abac:in swarm:FamilyMember;
    abac:name swarm:Role .

    swarm:Father
    abac:in swarm:AdultFamilyMember;
    abac:name swarm:Role .

    swarm:Father
    abac:in swarm:Boss;
    abac:name swarm:Role .
    """

    graph = Hierarchy.parse(graph_str)

    assert {"swarm:FamilyMember", "swarm:Children"} in graph
    assert {"swarm:AdultFamilyMember", "swarm:Father"} in graph
    assert {"swarm:Boss", "swarm:Father"} in graph
  end
end
