# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :smart_abac, hierarchy_client: SmartABAC.Hierarchy
config :smart_abac, hierarchy_file: "example_home_policy.n3"

config :smart_abac, debug_pdp: false

config :logger, level: :debug

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

import_config "#{Mix.env()}.exs"
