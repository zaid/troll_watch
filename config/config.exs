import Config

config :troll_watch, :auth_token, "none"
config :troll_watch, :port, "4000"
config :troll_watch, client: [region: "SCT"]

# Import environment specific config. This must remain at the bottom
# # of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
