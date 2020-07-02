defmodule ABACthem.Factory do
  # without Ecto
  use ExMachina.Ecto
  alias ABACthem.{Policy, Request}

  def policy_factory do
    %Policy{
      id: "123",
      name: "test policy",
      permissions: %{
        subject: %{"id" => "alice"},
        object: %{"owner" => "alice"},
        context: %{"dateTime" => %{"year" => 2020}},
        operations: ["create"]
      }
    }
  end

  def request_factory do
    %Request{
      subject: %{"id" => "alice"},
      object: %{"owner" => "alice"},
      context: %{"dateTime" => %{"year" => 2020}},
      operations: ["create"]
    }
  end
end
