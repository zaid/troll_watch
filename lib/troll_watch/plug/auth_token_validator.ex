defmodule TrollWatch.Plug.AuthTokenValidator do
  @moduledoc """
  Simple plug which checks the auth token for each request
  to make sure it is valid.
  """

  @behaviour Plug

  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    conn
    |> valid_auth_token?()
    |> case do
      true -> conn
      _ -> render_unauthorized(conn)
    end
  end

  # Private functions

  defp valid_auth_token?(conn) do
    auth_token_from_params(conn) == auth_token()
  end

  defp auth_token_from_params(conn) do
    conn
    |> fetch_query_params()
    |> Map.get(:query_params)
    |> Map.get("auth_token")
  end

  defp auth_token do
    Application.get_env(:troll_watch, :auth_token)
  end

  defp render_unauthorized(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:unauthorized, Jason.encode!(unauthorized_response_body()))
    |> halt()
  end

  defp unauthorized_response_body do
    %{error: "You need to specify a valid authentication token."}
  end
end
