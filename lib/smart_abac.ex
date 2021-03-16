defmodule SmartABAC do
  @moduledoc """
  Documentation for SmartABAC.
  """
  require Logger
  alias SmartABAC.{Policy, Request, Store, PDP}

  def list_authorized_policies(request, expand \\ true) do
    policies = list_policies()

    request
    |> setup_request(expand)
    |> PDP.list_authorized_policies(policies)
  end

  def authorize(request, expand \\ true) do
    policies = list_policies()

    request
    |> setup_request(expand)
    |> PDP.authorize(policies)
  end

  def setup_request(request, expand \\ true)

  def setup_request(request = %Request{}, expand) do
    request = if expand, do: Request.expand_attrs(request), else: request

    request
    |> Request.add_date_time()
  end

  def setup_request(request, expand) do
    {:ok, request} = build_request(request)
    setup_request(request, expand)
  end

  def list_policies do
    Store.all()
  end

  def create_policy(%SmartABAC.Policy{} = policy) do
    with :ok <- Store.update(policy) do
      {:ok, policy}
    else
      error ->
        error
    end
  end

  def create_policy(policy_attrs) do
    with {:ok, policy} <- build_policy(policy_attrs) do
      create_policy(policy)
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
