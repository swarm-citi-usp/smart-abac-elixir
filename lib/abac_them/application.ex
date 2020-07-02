defmodule ABACthem.Application do
  use Application

  def start(_type, _args) do
    children = [
      {ABACthem.Store, []},
      ABACthem.HierarchyStore
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
