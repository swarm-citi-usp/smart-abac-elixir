defmodule ABACthem.HierarchyClient do
  require Logger

  def expand_attr(name, value) do
    expansions_url = Application.get_env(:abac_them, :hierarchy_service_url)

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
