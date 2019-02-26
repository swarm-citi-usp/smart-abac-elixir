defmodule AC.Attr do
  defstruct data_type: "string", name: "", value: ""

  @type depends_on_data_type :: any

  @type t :: %__MODULE__{
          # The reasoning for this field is to aid programming languages to parse the attribute,
          # without needing a semantic inference engine to discover the data type
          data_type: :string | :number | map,
          name: String.t(),
          value: depends_on_data_type
        }
end
