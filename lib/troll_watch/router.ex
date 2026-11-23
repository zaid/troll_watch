defmodule TrollWatch.Router do
  use Plug.Router

  plug(Plug.Logger, log: :debug)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(CORSPlug, origin: "*", methods: ["GET", "DELETE"])
  plug(TrollWatch.Plug.AuthTokenValidator)
  plug(TrollWatch.Plug.BridgeStatuses)
  plug(:match)
  plug(:dispatch)

  match _ do
    send_resp(conn, :not_found, "invalid endpoint")
  end
end
