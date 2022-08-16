# Copyright (C) 2022 Geovane Fedrecheski <geonnave@gmail.com>
#               2022 Universidade de São Paulo
#               2022 LSI-TEC
#
# This file is part of the SwarmOS project, and it is subject to
# the terms and conditions of the GNU Lesser General Public License v2.1.
# See the file LICENSE in the top level directory for more details.

defmodule SmartABAC.Store do
  @moduledoc """
  Store, update and query local Policies.
  """

  # Agent and Supervisor functions

  def start_link(_ \\ []) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def child_spec(arg) do
    %{
      id: SmartABAC.Store,
      start: {SmartABAC.Store, :start_link, [arg]}
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
