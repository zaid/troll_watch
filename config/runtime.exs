import Config

config :troll_watch, :auth_token, System.fetch_env!("TROLL_WATCH_AUTH_TOKEN")
