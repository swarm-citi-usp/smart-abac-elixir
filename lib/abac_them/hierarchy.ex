defmodule ABACthem.Hierarchy do
  require Logger

  def start_link(_args \\ []) do
    Logger.info("Opening ABAC hierarchy...")

    Agent.start_link(fn ->
      Application.get_env(:abac_them, :hierarchy_file)
      |> open()
      |> parse()
      |> to_adjacency_list()
    end, name: __MODULE__)
  end

  def child_spec(arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [arg]}
    }
  end

  def get_graph() do
    Agent.get(__MODULE__, fn graph -> graph end)
  end

  def set_graph(graph_filename) do
    Agent.update(__MODULE__, fn _ ->
      graph_filename
      |> open()
      |> parse()
      |> to_adjacency_list()
    end)
  end

  def expand_attr(_name, value) do
    expand_attr(value)
  end

  def expand_attr(name) do
    get_graph()
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
    graph
    |> String.replace(~r/\n#.*\n/, "\n")
    |> String.split(".\n")
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

      {node, data["abac:in"]}
    end)
  end

  def open(filename) do
    Path.join(:code.priv_dir(:abac_them), filename)
    |> File.open!()
    |> IO.read(:all)
  end
end
