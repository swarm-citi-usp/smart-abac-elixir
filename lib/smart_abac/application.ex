# Copyright (C) 2022 Geovane Fedrecheski <geonnave@gmail.com>
#               2022 Universidade de São Paulo
#               2022 LSI-TEC
#
# This file is part of the SwarmOS project, and it is subject to
# the terms and conditions of the GNU Lesser General Public License v2.1.
# See the file LICENSE in the top level directory for more details.

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
