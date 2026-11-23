defmodule TrollWatch.Plug.BridgeStatuses do
  @moduledoc """
  Queries our internal cache for the latest brige statuses and returns
  it to the caller.
  """

  @behaviour Plug

  import Plug.Conn

  alias TrollWatch.Cache

  def init(options), do: options

  def call(%Plug.Conn{request_path: "/api/statuses"} = conn, _opts) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:ok, Jason.encode!(Cache.get_statuses()))
    |> halt()
  end

  def call(conn, _opts), do: conn
end
