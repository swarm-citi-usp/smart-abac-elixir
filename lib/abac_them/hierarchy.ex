defmodule ABACthem.Hierarchy do
  require Logger
  alias ABACthem.HierarchyStore

  def expand_attr(_name, value), do: expand_attr(value)

  def expand_attr(name) do
    HierarchyStore.get_graph()
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
        if n not in new_visited do
          {new_queue ++ [n], [n | new_visited]}
        else
          {new_queue, new_visited}
        end
      end)

    bfs(graph, new_queue, new_visited)
  end
end
