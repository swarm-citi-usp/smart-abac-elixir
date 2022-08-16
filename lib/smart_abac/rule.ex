# Copyright (C) 2022 Geovane Fedrecheski <geonnave@gmail.com>
#               2022 Universidade de São Paulo
#               2022 LSI-TEC
#
# This file is part of the SwarmOS project, and it is subject to
# the terms and conditions of the GNU Lesser General Public License v2.1.
# See the file LICENSE in the top level directory for more details.

defmodule SmartABAC.Rule do
  @moduledoc """
  Specifies a Rule.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:subject, :object, :context, :operations]}

  @primary_key false
  embedded_schema do
    field(:subject, :map, default: %{})
    field(:object, :map, default: %{})
    field(:context, :map, default: %{})
    field(:operations, {:array, {:map, :string}}, default: [])
  end

  def changeset(params) do
    %__MODULE__{}
    |> changeset(params)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:subject, :object, :context, :operations])
  end
end
