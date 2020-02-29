defmodule PerfTest do
  use ExUnit.Case
  alias ABACthem.{PDP, Attr, Policy, Request}

  @moduledoc """
  Some performance tests.
  """

  Code.require_file("./test/support.ex")

  def type do
    ["string", "number", "range"] |> Enum.random()
  end

  def name do
    ["Type", "Role", "Family", "Location"] |> Enum.random()
  end

  def value("string") do
    # :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)
    "KhH6Z3R5ZnSeAGRGA8r6Jg"
  end
  def value("number"), do: :rand.uniform()*10 |> Float.round(2)
  def value("range"), do: %{min: value("number"), max: value("number")}

  def attributes(n) do
    for _ <- 1..n do
      t = type()
      %Attr{data_type: t, name: name(), value: value(t)}
    end
  end

  def operations(n) do
    for _ <- 1..n do
      value("string")
    end
  end

  def policies(m, n) do
    for _ <- 1..m do
      %Policy{
        user_attrs: attributes(n),
        operations: operations(n),
        object_attrs: attributes(n),
        context_attrs: attributes(n)
      }
    end
  end

  def write_policies_to_file(ps, m, n) do
    File.write("./priv/generated/#{m}-#{n}.json", Poison.encode!(ps, pretty: true))
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

  def write_to_file(tests) do
    File.write("./priv/results.json", Poison.encode!(tests, pretty: true))
  end

  @tag :skip
  @tag timeout: :infinity
  test "perf" do
    tests = %{}

    result_warmup = run([5, 10, 15], [5, 10]) # warm up
    tests = Map.put(tests, :result_warmup, result_warmup)
    IO.puts("==== Warm up OK. Start real test ==== \n\n\n")

    result = run(Enum.take_every(500..2000, 500), [50, 100])
    # result = run(Enum.take_every(2000..2000, 500), [100])
    tests = Map.put(tests, :result, result)
    IO.puts("==== Regular test OK. ==== \n\n\n")

    # enable hierarchies
    ABACthem.Hierarchy.start_link()
    Application.put_env(:abac_them, :hierarchy_client, ABACthem.Hierarchy)
    result_h = run(Enum.take_every(500..2000, 500), [50, 100])
    tests = Map.put(tests, :result_h, result_h)
    # run([0, 5, 10], [5, 10])
    IO.puts("==== Hierarchy test OK. ==== \n\n\n")

    write_to_file(tests)
    System.cmd("python3", ["./priv/plot.py"]) |> IO.inspect
  end

  def run(m_list, n_list) do
    IO.write "Generating... "
    all_ps = generate_policies(m_list, n_list)
    IO.puts("\n\n")

    run_perf_test(all_ps, m_list, n_list) |> IO.inspect
  end

  def run_perf_test(all_ps, m_list, n_list) do
    {known_policy, request} = policy_and_request()

    for m <- m_list do
      for n <- n_list do
        IO.inspect("Will test #{inspect {n, m}}")
        tests =
          for _ <- 1..10 do
            IO.write(".")
            ps = all_ps[{m, n}]

            start_ms = start()
            refute PDP.authorize(Request.expand_attrs(request), ps)
            denied_ms = finish(start_ms)

            ps = insert_known_policy_at_half(ps, known_policy)
            write_policies_to_file(ps, m, n)
            start_ms = start()
            assert PDP.authorize(Request.expand_attrs(request), ps)
            allowed_ms = finish(start_ms)

            %{
              denied_ms: denied_ms,
              allowed_ms: allowed_ms
            }
          end

        IO.puts ""
        %{
          m: m, n: n,
          denied_ms: Enum.map(tests, fn test -> test[:denied_ms] end) |> Enum.sum |> Kernel./(length(tests)),
          allowed_ms: Enum.map(tests, fn test -> test[:allowed_ms] end) |> Enum.sum |> Kernel./(length(tests))
        }
      end
    end
    |> List.flatten()
  end

  def generate_policies(m_list, n_list) do
    for m <- m_list do
      for n <- n_list do
        IO.write(".")
        {
          {m, n}, policies(m, n)
        }
      end
    end
    |> List.flatten()
    |> Enum.into(%{})
  end

  def policy_and_request do
    policy_person = %Policy{
      id: "...",
      name: "Adult Home Control",
      user_attrs: [
        %Attr{data_type: "string", name: "swarm:Type", value: "swarm:Person"},
        %Attr{data_type: "range", name: "swarm:Age", value: %{min: 18.0, max: 100.0}}
      ],
      operations: ["read"],
      object_attrs: [
        %Attr{data_type: "string", name: "swarm:Type", value: "swarm:AirConditioner"}
      ]
    }

    request = %Request{
      user_attrs: %{
        "swarm:Id" => "swarm:1atJsQno5yjJE7raHWSV4Py3b9BndatXGzbB88f7QYsZLhvHSG",
        "swarm:Type" => "swarm:Person",
        "swarm:Age" => 25.0
      },
      object_attrs: %{
        "swarm:Type" => "swarm:AirConditioner",
        "swarm:Location" => "swarm:Kitchen"
      },
      operations: ["read"]
    }

    {policy_person, request}
  end
end
