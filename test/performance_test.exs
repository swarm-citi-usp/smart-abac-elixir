defmodule PerformanceTest do
  use ExUnit.Case
  require Logger
  doctest ABACthem
  import ABACthem.Factory
  alias ABACthem.{Policy, Request, HierarchyStore, Serialization, PDP}

  test "create policy" do
    HierarchyStore.set_graph_from_file("example_home_policy.n3")

    assert {:ok, "[]"} = load_policies(0, 0)
    assert {:error, msg} = load_policies(0, 1)
  end

  test "generate policies" do
    policies = generate(2, 2)
    assert 2 == length(policies)
  end

  # @tag :skip
  test "run the test" do
    # run(500, 50)
    for m <- [500, 1000, 1500, 2000] do
      for n <- [50, 100] do
    # for m <- [20] do
    #   for n <- [5] do
        run(m, n)
      end
    end
  end

  def run(m, n) do
    Logger.debug("Will run for n=#{n} and m=#{m}")
    policies =
      load_policies(m, n)
      |> case do
        {:ok, policies} ->
          Logger.debug("Using loaded policies")
          policies
        {:error, _} ->
          Logger.debug("Generating policies")
          policies = generate(m, n)
          save_policies(policies, m, n)
          policies
      end

    {:ok, known_policy} = params_for(:policy) |> ABACthem.build_policy()
    policies = insert_known_policy_at_half(policies, known_policy)
    {:ok, request} = params_for(:request) |> ABACthem.build_request()

    runs = 10
    sum = 0
    for _ <- 0..runs do
      start_ms = start()
      assert PDP.authorize(request, policies)
      final_ms = finish(start_ms)
      Logger.info("Authz took #{final_ms} ms")
      sum = sum + final_ms
    end
    avg = sum / runs
    Logger.debug("Average authz took #{avg} ms")
  end

  def insert_known_policy_at_half(ps, known_policy) do
    List.insert_at(ps, trunc(length(ps) / 2), known_policy)
  end

  def start do
    System.monotonic_time(:millisecond)
  end

  def finish(start_ms) do
    end_ms = System.monotonic_time(:millisecond)
    end_ms - start_ms
  end

  def generate(m, n) do
    for _ <- 1..m do
      new_policy(n)
    end
  end

  def new_policy(n) do
    %{
      id: "KhH6Z3R5ZnSeAGRGA8r6Jg",
      name: "some policy",
      permissions: %{
        subject: attributes(n),
        object: attributes(n),
        context: attributes(n),
        operations: ["some", "operations"],
      }
    }
  end

  def attributes(n) do
    for _ <- 1..n do
      ["string", "number", "range", "object"]
      |> Enum.random()
      |> case do
        "string" ->
          %{"key-#{:rand.uniform(100_000)}" => "some value"}
        "number" ->
          %{"key-#{:rand.uniform(100_000)}" => 123}
        "range" ->
          %{"key-#{:rand.uniform(100_000)}" => %{"min" => 123, "max" => 456}}
        "object" ->
          %{"key-#{:rand.uniform(100_000)}" => %{"inner key" => "inner value"}}
      end
    end
    |> Enum.reduce(fn x, acc -> Map.merge(x, acc) end)
  end

  def load_policies(m, n) do
    local_file = "/benchmark/policies_#{m}-#{n}.json"
    Logger.debug("Opening file #{local_file}")

    Path.join(:code.priv_dir(:abac_them), local_file)
    |> File.open()
    |> case do
      {:ok, file} ->
        Serialization.from_json(IO.read(file, :all))
      error ->
        error
    end
  end

  def save_policies(policies, m, n) do
    filename = Path.join(:code.priv_dir(:abac_them), "/benchmark/policies_#{m}-#{n}.json")
    {:ok, json_policies} = Serialization.to_json(policies, pretty: true)
    File.write(filename, json_policies)
  end
end
