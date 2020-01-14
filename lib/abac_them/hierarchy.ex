defmodule ABACthem.Hierarchy do
  def expand_attr(_name, value) do
    expand_attr(value)
  end

  def expand_attr(name) do
    "abac_them_hierarchy/tests/example_home_policy.n3"
    |> open()
    |> parse()
    |> to_adjacency_list()
    |> find_ancestors(name)
  end

  def find_ancestors(graph, name) do
    [name | bfs(graph, [name], [])]
  end

  def bfs(_graph, _queue = [], visited) do
    visited
  end

  def bfs(graph, queue, visited) do
    [s | queue] = queue

    {new_queue, new_visited} =
      Enum.reduce(graph[s] || [], {queue, visited}, fn n, {new_queue, new_visited} ->
        if n not in visited do
          {new_queue ++ [n], [n | new_visited]}
        else
          {new_queue, new_visited}
        end
      end)

    bfs(graph, new_queue, new_visited)
  end

  def to_adjacency_list(edges) do
    edges
    |> Enum.reduce(%{}, fn {a, b}, acc ->
      if acc[a] do
        Map.put(acc, a, [b | acc[a]])
      else
        Map.put(acc, a, [b])
      end
    end)
  end

  def parse(graph) do
    String.split(graph, ".\n")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(fn e ->
      e == "" || e =~ "prefix" || e =~ ~r/^#/
    end)
    |> Enum.map(fn item ->
      [node, rest] = String.split(item, [" ", "\n"], parts: 2)

      data =
        String.split(rest, ";")
        |> Enum.map(fn edge ->
          [e, n] = String.trim(edge) |> String.split(" ")
          {e, n}
        end)
        |> Enum.into(%{})

      {data["abac:in"], node}
    end)
  end

  def open(filename) do
    Path.join(:code.priv_dir(:abac_them), filename)
    |> File.open!()
    |> IO.read(:all)
  end
end
