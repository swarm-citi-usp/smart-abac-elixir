defmodule ABACthem.Attr do
  @moduledoc """
  Defines general attributes. Can be user, object, or context attributes.

  # User Attributes
  TO-DO

  # Object Attributes
  TO-DO

  # Context Attributes
  Regards attributes that do not fit neither Users nor Objects.
  In the literature, such attributes have been classififed as "Situational", "Environmental", or "Contextual" attributes.
  It is important that we define what kind of attributes we need, in order to adopt them to our model.

  Some examples of context attributes are listed below:

    * Date and time
    * Location (although this could be used as User or Object attribute)
    * Temperature
    * Humidity
    * Threat level
    * Emergency level
    * Wheather conditions
  """

  defstruct data_type: "string", name: "", value: ""

  @type depends_on_data_type :: any

  @type t :: %__MODULE__{
          # The reasoning for this field is to aid programming languages to parse the attribute,
          # without needing a semantic inference engine to discover the data type
          data_type: :string | :number | map,
          name: String.t(),
          value: depends_on_data_type
        }

  def simple_encode([]) do
    "[]"
  end

  def simple_encode(attrs) when is_list(attrs) do
    """
    [
          #{Enum.map(attrs, &simple_encode/1) |> Enum.join(",\n      ")}
        ]\
    """
  end

  def simple_encode(%{data_type: dt, name: name, value: value}) do
    "[#{dt}, #{name}, #{simple_encode(value)}]"
  end

  def simple_encode(value = %{}) do
    Poison.encode!(value)
  end

  def simple_encode(value) do
    value
  end
end
