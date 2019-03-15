defmodule Ac.Request do
  defstruct user_attrs: %{}, object_attrs: %{}, operations: []

  @type t :: %__MODULE__{
          user_attrs: [Attr.t()],
          operations: [String.t()],
          object_attrs: [Attr.t()]
        }
end
