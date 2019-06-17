defmodule ABACthem do
  @moduledoc """
  Documentation for ABACthem.
  """

  def authorize(request) do
    request = ABACthem.Request.expand_attrs(request)
    # TODO: implement this
    # request = ABACthem.Request.add_date_time(request)
    policies = ABACthem.Store.all()
    ABACthem.PDP.authorize(request, policies)
  end
end
