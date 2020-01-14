defmodule ABACthem do
  @moduledoc """
  Documentation for ABACthem.
  """

  def authorize(request) do
    policies = ABACthem.Store.all()

    request
      |> ABACthem.Request.expand_attrs()
      |> IO.inspect
      |> ABACthem.Request.add_date_time_attr()
      |> ABACthem.PDP.authorize(policies)
  end
end
