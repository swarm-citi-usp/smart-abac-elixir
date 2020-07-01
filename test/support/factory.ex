defmodule ABACthem.Factory do
  # without Ecto
  use ExMachina.Ecto
  alias ABACthem.{PolicyV2, RequestV2}

  def policy_factory do
    %PolicyV2{
      id: "123",
      name: "test policy",
      privileges: %{
        subject: %{"id" => "alice"},
        object: %{"owner" => "alice"},
        context: %{"dateTime" => %{"year" => 2020}},
        operations: ["create"],
      }
    }
  end

  def request_factory do
    %RequestV2{
      subject: %{"id" => "alice"},
      object: %{"owner" => "alice"},
      context: %{"dateTime" => %{"year" => 2020}},
      operations: ["create"],
    }
  end
end
