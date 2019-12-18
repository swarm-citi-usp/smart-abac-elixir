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

  def value do
    # :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)
    "KhH6Z3R5ZnSeAGRGA8r6Jg"
  end

  def attributes(n) do
    for _ <- 1..n do
      %Attr{data_type: type(), name: name(), value: value()}
    end
  end

  def operations(n) do
    for _ <- 1..n do
      value()
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

  test "perf" do
    run([5, 10], [5, 10]) # warm up
    IO.puts("==== Warm up OK. Start real test ==== \n\n\n")

    run(Enum.take_every(400..2000, 400), [1, 10, 100])
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
        test = %{m: m, n: n, denied_ms: nil, allowed_ms: nil}
        ps = all_ps[{m, n}]

        start_ms = start()
        refute PDP.authorize(request, ps)
        denied_ms = finish(start_ms)

        ps = insert_known_policy_at_half(ps, known_policy)
        start_ms = start()
        assert PDP.authorize(request, ps)
        allowed_ms = finish(start_ms)

        %{
          test |
          denied_ms: denied_ms,
          allowed_ms: allowed_ms
        }
      end
    end
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
        %Attr{data_type: "string", name: "Type", value: "Person"},
        %Attr{data_type: "range", name: "Age", value: %{min: 18}}
      ],
      operations: ["read"],
      object_attrs: [
        %Attr{data_type: "string", name: "Type", value: "AirConditioner"}
      ]
    }

    request = %Request{
      user_attrs: %{
        "Id" => "1atJsQno5yjJE7raHWSV4Py3b9BndatXGzbB88f7QYsZLhvHSG",
        "Type" => "Person",
        "Age" => 25
      },
      object_attrs: %{
        "Type" => "AirConditioner",
        "Location" => "Kitchen"
      },
      operations: ["read"]
    }

    {policy_person, request}
  end
end
