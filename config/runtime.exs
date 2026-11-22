import Config

config :troll_watch, :auth_token, System.fetch_env!("TROLL_WATCH_AUTH_TOKEN")
config :troll_watch, :port, System.get_env("TROLL_WATCH_PORT", "4000")
config :troll_watch, client: [region: "SCT"]
