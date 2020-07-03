defmodule PerformanceTest do
  use ExUnit.Case
  require Logger
  doctest ABACthem
  import ABACthem.Factory
  alias ABACthem.{Policy, Request, HierarchyStore, Serialization, PDP}

  test "generate, save, and load policies" do
    HierarchyStore.set_graph_from_file("example_home_policy.n3")
    policies = generate(2, 2)
    assert 2 == length(policies)
    save_policies(policies, 2, 2)
    assert {:ok, _} = load_policies(2, 2)
  end

  test "run a small test" do
    wrapper_run([10, 20], [5])
  end

  # @tag :skip
  @tag timeout: :infinity
  test "run the real test" do
    wrapper_run([500, 1000, 1500, 2000], [50, 100])
  end

  def wrapper_run(steps_m, steps_n) do
    setup_results_csv(steps_m, steps_n)
    for m <- steps_m do
      for n <- steps_n do
        t = run(m, n)
        append_results_csv([m, n, t], steps_m, steps_n)
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
    sum =
      for _ <- 0..runs do
        start_ms = start()
        assert PDP.authorize(request, policies)
        spent_ms = finish(start_ms)
        Logger.debug(">>> authz took #{spent_ms} ms")
        spent_ms
      end
      |> Enum.reduce(fn x, acc -> x + acc end)
    avg = sum / runs
    Logger.debug("Average authz took #{avg} ms")
    avg
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

  def save_results(results, steps_m, steps_n) do
    filename = Path.join(:code.priv_dir(:abac_them), "/benchmark/policies_#{steps_m}-#{steps_n}.json")
    File.write(filename, Jason.encode!(results))
  end

  def append_results_csv([m, n, t], steps_m, steps_n) do
    file = "policies_#{inspect steps_m}-#{inspect steps_n}.csv"
    filename = Path.join(:code.priv_dir(:abac_them), "/benchmark/#{file}")
    File.write(filename, "#{m},#{n},#{t}\n", [:append])
  end

  def setup_results_csv(steps_m, steps_n) do
    file = "policies_#{inspect steps_m}-#{inspect steps_n}.csv"
    filename = Path.join(:code.priv_dir(:abac_them), "/benchmark/#{file}")
    File.write(filename, "policies, attributes, spent time\n")
  end
end
