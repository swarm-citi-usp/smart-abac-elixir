defmodule ABACthem.HierarchyClient do
  require Logger

  def get_attr_containers(value) do
    containers_url = "http://localhost:4010/containers"
    attribute_json = Poison.encode!(%{attribute: value})
    headers = [{"content-type", "application/json"}]

    with {:ok, %{body: body, status: 200}} <-
           Tesla.post(containers_url, attribute_json, headers: headers),
         {:ok, containers} <- Poison.decode(body, keys: :atoms) do
      containers
    else
      error ->
        Logger.warn("Failed to get attribute containers: " <> inspect(error))
        []
    end
  end

  def expand_attr(name, value) do
    expansions_url = "http://localhost:4010/expansions"
    attribute_json = Poison.encode!(%{name: name, value: value})
    headers = [{"content-type", "application/json"}]

    with {:ok, %{body: body, status: 200}} <-
           Tesla.post(expansions_url, attribute_json, headers: headers),
         {:ok, expanded_attrs} <- Poison.decode(body, keys: :atoms) do
      expanded_attrs
    else
      error ->
        Logger.warn("Failed to get expanded attributes: " <> inspect(error))
        [value]
    end
  end
end
