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

  def child_spec(opts) do
    %{id: __MODULE__, restart: :permanent, start: {__MODULE__, :start_link, opts}, type: :worker}
  end

  def start_link(opts \\ []) do
    port = Application.get_env(:troll_watch, :port)

    {:ok, _pid} = Bandit.start_link(Keyword.merge(opts, plug: __MODULE__, port: port))
  end
end
