defmodule SmartABAC.Application do
  use Application

  def start(_type, _args) do
    children = [
      {SmartABAC.Store, []},
      SmartABAC.HierarchyStore
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
