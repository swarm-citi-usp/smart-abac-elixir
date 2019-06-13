defmodule ABACthem.Store do
  @moduledoc """
  Store, update and query local Policies.
  """

  # Agent and Supervisor functions

  def start_link(_ \\ []) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def child_spec(arg) do
    %{
      id: ABACthem.Store,
      start: {ABACthem.Store, :start_link, [arg]}
    }
  end

  # public API functions

  def all(), do: Agent.get(__MODULE__, &Enum.map(&1, fn {_id, p} -> p end))

  def read(policy_id), do: Agent.get(__MODULE__, & &1[policy_id])

  def has?(policy_id),
    do: Agent.get(__MODULE__, &Enum.find(&1, fn {_id, p} -> p.id == policy_id end))

  def update(policy) do
    Agent.update(__MODULE__, fn policies ->
      put_in(policies[policy.id], policy)
    end)
  end

  def delete(policy_id), do: Agent.update(__MODULE__, &Map.delete(&1, policy_id))

  def reset, do: Agent.update(__MODULE__, fn _ -> %{} end)
end
