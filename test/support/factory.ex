defmodule SmartABAC.Factory do
  # without Ecto
  use ExMachina.Ecto
  alias SmartABAC.{Policy, Request}

  def policy_factory do
    %Policy{
      id: "123",
      name: "test policy",
      permissions: %{
        subject: %{"id" => "alice"},
        object: %{"owner" => "alice"},
        context: %{"dateTime" => %{"year" => Date.utc_today.year}},
        operations: [%{"@type" => "create"}]
      }
    }
  end

  def request_factory do
    %Request{
      subject: %{"id" => "alice"},
      object: %{"owner" => "alice"},
      context: %{"dateTime" => %{"year" => Date.utc_today.year}},
      operations: [%{"@type" => "create"}]
    }
  end

  def request_expanded_factory do
    %Request{
      subject: %{"id" => "alice"},
      object: %{"owner" => ["Alice","alice","a l i c e"]},
      context: %{"dateTime" => %{"year" => Date.utc_today.year}},
      operations: [%{"@type" => "create"}]
    }
  end
end
