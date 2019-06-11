defmodule ABACthem.LogDecorator do
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
