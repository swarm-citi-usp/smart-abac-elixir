defmodule ABACthem do
  @moduledoc """
  Documentation for ABACthem.
  """
  require Logger
  alias ABACthem.{Policy, Request, Store, PDP}

  def authorize(request, expand \\ true)

  def authorize(request = %Request{}, expand) do
    policies = list_policies()
    request = if expand, do: Request.expand_attrs(request), else: request

    request
    |> Request.add_date_time()
    |> PDP.authorize(policies)
  end

  def authorize(request, expand) do
    with {:ok, request} <- build_request(request) do
      authorize(request, expand)
    else
      error ->
        Logger.warn("Error (#{inspect error}) on request: #{inspect request}")
        false
    end
  end

  def list_policies do
    Store.all()
  end

  def create_policy(policy_attrs) do
    with {:ok, policy} <- build_policy(policy_attrs),
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

  def build_policy(policy_attrs) do
    with changeset = %{valid?: true} <- Policy.changeset(policy_attrs) do
      {:ok, Ecto.Changeset.apply_changes(changeset)}
    else
      error ->
        error
    end
  end

  def build_request(request_attrs) do
    with changeset = %{valid?: true} <- Request.changeset(request_attrs) do
      {:ok, Ecto.Changeset.apply_changes(changeset)}
    else
      error ->
        error
    end
  end
end
