defmodule ABACthem.RequestV2 do
  @moduledoc """
  Specifies a RequestV2.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :subject, :map
    field :object, :map
    field :context, :map
    field :operations, {:array, :string}
  end

  def changeset(params) do
    %__MODULE__{}
    |> changeset(params)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:subject, :object, :context, :operations])
  end

  def add_date_time(request) do
    {:ok, dt} = DateTime.now("America/Sao_Paulo")

    context = Map.merge(request.context, %{
      "dateTime" => %{
        "second" => dt.second, "minute" => dt.minute, "hour" => dt.hour, "day" => dt.day, 
        "month" => dt.month, "year" => dt.year, "timeZone" => dt.time_zone
      }
    })

    %{request | context: context}
  end
end
