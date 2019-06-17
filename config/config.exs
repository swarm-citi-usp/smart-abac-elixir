# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :abac_them, hierarchy_client: ABACthem.HierarchyClient
config :abac_them, hierarchy_service_url: "http://localhost:4010/expansions"

import_config "#{Mix.env()}.exs"
