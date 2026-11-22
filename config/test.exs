import Config

config :troll_watch, :client, retry: false, plug: {Req.Test, TrollWatch.Client}
