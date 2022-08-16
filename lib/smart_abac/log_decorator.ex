# Copyright (C) 2022 Geovane Fedrecheski <geonnave@gmail.com>
#               2022 Universidade de São Paulo
#               2022 LSI-TEC
#
# This file is part of the SwarmOS project, and it is subject to
# the terms and conditions of the GNU Lesser General Public License v2.1.
# See the file LICENSE in the top level directory for more details.

defmodule SmartABAC.LogDecorator do
  use Decorator.Define, log: 1

  def log(level, body, _context = %{name: name, args: [request_data, policy_data]}) do
    quote do
      result = unquote(body)

      require Logger

      Logger.log(
        unquote(level),
        "Matching #{unquote(name)}(#{inspect(unquote(request_data))}, #{
          inspect(unquote(policy_data))
        }) was #{result}"
      )

      result
    end
  end
end
