# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :lgame, LgameWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "b7/7vsaa1/hpKyFZzJKiBbCPXw5mWrDgYwvNl8yRXAFQBa8apH4+IxTUsDLsLCzH",
  render_errors: [view: LgameWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Lgame.PubSub,
  live_view: [signing_salt: "Xpcz/M0f"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :lgame,
  ga_tracking_code: "",
  # Number of bytes for generic unique id
  id_length: 8,
  # Number of words used in game ids "ahoy-matey"
  id_words: 2,
  # Maximal number >= 100 after the words "ahoey-matey-9999".
  id_number_max: 9999

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
