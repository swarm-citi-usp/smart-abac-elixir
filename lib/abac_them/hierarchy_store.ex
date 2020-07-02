defmodule ABACthem.HierarchyStore do
  require Logger

  def start_link(_args \\ []) do
    Logger.info("Opening ABAC hierarchy...")

    Agent.start_link(
      fn ->
        graph_filename = Application.get_env(:abac_them, :hierarchy_file)
        load(graph_filename)
      end,
      name: __MODULE__
    )
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

  def set_graph(graph) do
    Agent.update(__MODULE__, fn _ ->
      graph
    end)
  end

  def set_graph_from_file(graph_filename) do
    Agent.update(__MODULE__, fn _ ->
      load(graph_filename)
    end)
  end

  def load(graph_filename) do
    graph_filename
    |> open()
    |> parse()
    |> to_adjacency_list()
  end

  def open(filename) do
    Path.join(:code.priv_dir(:abac_them), filename)
    |> File.open!()
    |> IO.read(:all)
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
end
