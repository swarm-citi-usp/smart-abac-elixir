defmodule HierarchyTest do
  use ExUnit.Case
  alias SmartABAC.{Hierarchy, HierarchyStore}

  test "expand attrs" do
    HierarchyStore.set_graph_from_file("example_home_policy.n3")

    assert [
             "swarm:AdultFamilyMember",
             "swarm:FamilyMember",
             "swarm:Father",
             "swarm:Persona"
           ] == Hierarchy.expand_attr("swarm:Father") |> Enum.sort()

    assert ["swarm:FamilyMember", "swarm:Persona"] ==
             Hierarchy.expand_attr("swarm:FamilyMember") |> Enum.sort()

    assert [
             "swarm:Appliance",
             "swarm:SecurityAppliance",
             "swarm:SecurityCamera"
           ] == Hierarchy.expand_attr("swarm:SecurityCamera") |> Enum.sort()
  end

  test "run bfs" do
    graph = %{
      "a" => ["c"],
      "b" => ["c"],
      "c" => ["d"],
      "d" => [],
      "e" => ["g", "d"],
      "f" => ["e"],
      "h" => []
    }

    assert ["c", "d"] = Hierarchy.bfs(graph, ["a"], []) |> Enum.sort()
    assert ["c", "d"] = Hierarchy.bfs(graph, ["b"], []) |> Enum.sort()
    assert [] = Hierarchy.bfs(graph, ["d"], [])
    assert ["d", "e", "g"] = Hierarchy.bfs(graph, ["f"], []) |> Enum.sort()
  end

  test "parse graph from file" do
    graph_str = HierarchyStore.open("example_home_policy.n3")

    graph =
      HierarchyStore.parse(graph_str)
      |> HierarchyStore.to_adjacency_list()

    assert ["swarm:Acquaintance"] == graph["swarm:Friend"]
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

    graph = HierarchyStore.parse(graph_str)

    assert {"swarm:Children", "swarm:FamilyMember"} in graph
    assert {"swarm:Father", "swarm:AdultFamilyMember"} in graph
    assert {"swarm:Father", "swarm:Boss"} in graph
  end
end
