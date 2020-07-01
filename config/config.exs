# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :abac_them, hierarchy_client: ABACthem.Hierarchy#Client
config :abac_them, hierarchy_file: "example_home_policy.n3"

config :abac_them, hierarchy_service_url: "http://localhost:4010/expansions"
config :abac_them, debug_pdp: false

config :logger, level: :error

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

import_config "#{Mix.env()}.exs"
