# Copyright (C) 2022 Geovane Fedrecheski <geonnave@gmail.com>
#               2022 Universidade de São Paulo
#               2022 LSI-TEC
#
# This file is part of the SwarmOS project, and it is subject to
# the terms and conditions of the GNU Lesser General Public License v2.1.
# See the file LICENSE in the top level directory for more details.

defmodule PerformanceTest do
  use ExUnit.Case
  require Logger
  doctest SmartABAC
  import SmartABAC.Factory
  alias SmartABAC.{HierarchyStore, Serialization, PDP}

  test "generate, save, and load policies" do
    HierarchyStore.set_graph_from_file("example_home_policy.n3")
    policies = generate(2, 2)
    assert 2 == length(policies)
    save_policies(policies, 2, 2)
    assert {:ok, _} = load_policies(2, 2)
  end

  test "compare sizes" do
    {:ok, policy} = params_for(:policy) |> SmartABAC.build_policy()

    {:ok, policy_json} = Serialization.to_json(policy)
    {:ok, policy_cbor} = Serialization.to_cbor(policy)
    # {:ok, policy_cbor} = Serialization.to_cbor(policy, :hex) |> IO.inspect

    jl = String.length(policy_json)
    cl = String.length(policy_cbor)

    Logger.info(
      "JSON length: #{jl}, CBOR length: #{cl}, ratio: #{Float.round(cl / jl, 2) * 100}%"
    )
  end

  @tag :skip
  @tag timeout: :infinity
  test "run a small test" do
    wrapper_run([10, 20], [5])
  end

  @tag :skip
  @tag timeout: :infinity
  test "run the real test" do
    # warm up
    wrapper_run([10, 20], [5])

    # real test
    wrapper_run([100, 500, 1000, 1500, 2000, 2500, 3000], [10, 100, 200])
  end

  @tag :skip
  @tag timeout: :infinity
  test "run 1 request against 6 policies 3000 times" do
    {:ok, policies} =
      paper_policies()
      |> SmartABAC.Serialization.from_json()

    for p <- policies do
      SmartABAC.Store.update(p)
    end

    {:ok, request} = paper_request("3")
    assert SmartABAC.authorize(request)

    Process.sleep(1000)
    Process.sleep(100 + :random.uniform(100))
    start_ms = start()

    for _i <- 1..3000 do
      SmartABAC.authorize(request)
    end

    spent_ms = finish(start_ms)

    Logger.debug(
      "The time taken to authorize 1 request against 6 policies, 3000 times, was #{spent_ms} ms"
    )
  end

  @tag :skip
  @tag timeout: :infinity
  test "run 1 request against 3 policies 3000 times" do
    {:ok, policies} =
      paper_3_policies()
      |> SmartABAC.Serialization.from_json()

    for p <- policies do
      SmartABAC.Store.update(p)
    end

    {:ok, request} = paper_request("1")
    assert SmartABAC.authorize(request)

    t = 20

    sum =
      Enum.reduce(0..t, 0, fn _j, acc ->
        Process.sleep(25 + :random.uniform(25))
        start_ms = start()

        for _i <- 1..3000 do
          SmartABAC.authorize(request)
        end

        spent_ms = finish(start_ms)
        acc + spent_ms
      end)

    avg = sum / t

    Logger.debug(
      "The time taken to authorize 1 request against 3 policies, 3000 times, was #{avg} ms"
    )
  end

  def wrapper_run(steps_m, steps_n) do
    setup_results_csv(steps_m, steps_n)

    for m <- Enum.shuffle(steps_m) do
      for n <- Enum.shuffle(steps_n) do
        runs = 5

        sum =
          for _ <- 1..runs do
            run(m, n)
          end
          |> Enum.reduce(fn x, acc -> x + acc end)

        t = sum / runs
        Logger.debug("=== Average authz took #{t} ms ===")
        append_results_csv([m, n, t], steps_m, steps_n)
      end
    end
  end

  def run(m, n) do
    Logger.debug(">>> Will run for n=#{n} and m=#{m}")

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

    {:ok, known_policy} = params_for(:policy) |> SmartABAC.build_policy()
    policies = insert_known_policy_at_half(policies, known_policy)
    {:ok, request} = params_for(:request_expanded) |> SmartABAC.build_request()

    Process.sleep(3000)
    Process.sleep(100 + :random.uniform(100))
    start_ms = start()
    assert PDP.authorize(request, policies)
    spent_ms = finish(start_ms)
    IO.write(" #{spent_ms} ")
    # Logger.debug("Average authz took #{avg} ms")
    spent_ms
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
        operations: [%{"@type" => "some"}, %{"@type" => "operations"}]
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

    Path.join(:code.priv_dir(:smart_abac), local_file)
    |> File.open()
    |> case do
      {:ok, file} ->
        Logger.debug("Parsing json")
        Serialization.from_json(IO.read(file, :all))

      error ->
        error
    end
  end

  def save_policies(policies, m, n) do
    filename = Path.join(:code.priv_dir(:smart_abac), "/benchmark/policies_#{m}-#{n}.json")
    {:ok, json_policies} = Serialization.to_json(policies, pretty: true)
    File.write(filename, json_policies)
  end

  def append_results_csv([m, n, t], steps_m, steps_n) do
    {pathname, filename} = results_filename(steps_m, steps_n)
    t = "\"#{t}\"" |> String.replace(".", ",")
    File.write("#{pathname}/#{filename}", "#{m},#{n},#{t}\n", [:append])
  end

  def setup_results_csv(steps_m, steps_n) do
    {pathname, filename} = results_filename(steps_m, steps_n)
    File.mkdir(pathname)
    Logger.debug("Results go to file #{pathname}/#{filename}")
    File.write("#{pathname}/#{filename}", "policies, attributes, spent time\n")
  end

  def results_filename(steps_m, steps_n) do
    pathname = Path.join(:code.priv_dir(:smart_abac), "/benchmark/")
    filename = "results_#{inspect(steps_m)}-#{inspect(steps_n, charlists: :as_lists)}.csv"
    {pathname, filename}
  end

  def paper_request(id) do
    %{
      "1" => %{
        "subject" => %{"id" => "alice"},
        "object" => %{"owner" => "alice"},
        "operations" => [%{"@type" => "read"}]
      },
      "3" => %{
        "subject" => %{"household" => %{"id" => "home-1", "role" => "child"}},
        "object" => %{"type" => "lightingAppliance", "household" => %{"id" => "home-1"}},
        "context" => %{"outdoorLuminosity" => 25},
        "operations" => [%{"@type" => "read"}]
      },
      "6" => %{
        "subject" => %{"id" => "some-device-x"},
        "object" => %{"id" => "camera1"},
        "context" => %{"year" => 2020, "month" => 1, "day" => 1, "hour" => 17, "minute" => 21},
        "operations" => [%{"@type" => "read"}]
      }
    }[id]
    |> SmartABAC.build_request()
  end

  def paper_3_policies do
    """
    [
      {
        "id": "1",
        "permissions": {
            "subject": {"id": "alice"},
            "object": {"owner": "alice"},
            "operations": [{"@type": "create"}, {"@type": "read"}, {"@type": "update"}, {"@type": "delete"}]
        }
      }, {
        "id": "4",
        "permissions": {
            "subject": {"id": "camera1"},
            "object": {"id": "lamp1"},
            "operations": [{"@type": "read"}, {"@type": "update"}]
        }
      }, {
        "id": "6",
        "permissions": {
            "subject": {"id": "some-device-x"},
            "object": {"id": "camera1"},
            "context": {"year": 2020, "month": 1, "day": 1, "hour": 17, "minute": {"min": 20, "max": 25}},
            "operations": [{"@type": "read"}]
        }
      }
    ]
    """
  end

  def paper_policies do
    """
    [
      {
        "id": "1",
        "permissions": {
            "subject": {"id": "alice"},
            "object": {"owner": "alice"},
            "operations": [{"@type": "create"}, {"@type": "read"}, {"@type": "update"}, {"@type": "delete"}]
        }
      }, {
        "id": "2",
        "permissions": {
            "subject": {"age": {"min": 18}, "household": {"id": "home-1"}},
            "object": {"type": "securityAppliance", "household": {"id": "home-1"}},
            "operations": [{"@type": "read"}, {"@type": "update"}]
        }
      }, {
        "id": "3",
        "permissions": {
            "subject": {"household": {"id": "home-1", "role": "child"}},
            "object": {"type": "lightingAppliance", "household": {"id": "home-1"}},
            "context": {"outdoorLuminosity": {"max": 33}},
            "operations": [{"@type": "read"}, {"@type": "update"}]
        }
      }, {
        "id": "4",
        "permissions": {
            "subject": {"id": "camera1"},
            "object": {"id": "lamp1"},
            "operations": [{"@type": "read"}, {"@type": "update"}]
        }
      }, {
        "id": "5",
        "permissions": {
            "subject": {"reputation": {"min": 4}},
            "object": {"type": "securityCamera", "household": {"id": "home-1"}, "location": "outdoor"},
            "context": {"hour": {"min": 8, "max": 18}},
            "operations": [{"@type": "contract"}]
        }
      }, {
        "id": "6",
        "permissions": {
            "subject": {"id": "some-device-x"},
            "object": {"id": "camera1"},
            "context": {"year": 2020, "month": 6, "day": 30, "hour": 17, "minute": {"min": 20, "max": 25}},
            "operations": [{"@type": "read"}]
        }
      }
    ]
    """
  end
end
