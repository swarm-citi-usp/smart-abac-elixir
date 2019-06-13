defmodule ABACthem.Store do
  @moduledoc """
  Store, update and query local Policies.
  """

  def start_link(_ \\ []) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def read_all, do: Agent.get(__MODULE__, &Enum.map(&1, fn {_id, p} -> p end))

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
