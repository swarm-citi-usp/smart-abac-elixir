defmodule ABACthem do
  @moduledoc """
  Documentation for ABACthem.
  """
  alias ABACthem.{PolicyV2, RequestV2, Store, PDPv2}

  def authorize(request) do
    policies = list_policies()

    request
      |> ABACthem.Request.expand_attrs()
      |> ABACthem.Request.add_date_time_attr()
      |> ABACthem.PDP.authorize(policies)
  end

  def authorize_v2(request) do
    policies = list_policies()

    request
      # |> RequestV2.expand_attrs()
      |> RequestV2.add_date_time()
      |> IO.inspect
      |> PDPv2.authorize(policies)
  end

  def list_policies do
    Store.all()
  end

  def create_policy(policy_attrs) do
    with changeset = %{valid?: true} <- PolicyV2.changeset(policy_attrs),
         policy <- Ecto.Changeset.apply_changes(changeset),
         :ok <- Store.update(policy) do
      {:ok, policy}
    else
      error ->
        error
    end
  end

  def get_policy(id) do
    Store.read(id)
  end

  def delete_policy(id) do
    Store.delete(id)
  end

  def build_request(request_attrs) do
    with changeset = %{valid?: true} <- RequestV2.changeset(request_attrs) do
      {:ok, Ecto.Changeset.apply_changes(changeset)}
    else
      error ->
        error
    end
  end
end
