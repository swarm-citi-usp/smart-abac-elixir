defmodule ABACthem.Serialization do
  @moduledoc """
  Serialize policies to and from json.
  """
  alias ABACthem.{PolicyV2, RequestV2, Store, PDPv2}

  def to_json(policy) do
    Jason.encode!(policy)
  end
end
