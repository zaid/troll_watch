defmodule TrollWatch.Plug.BridgeStatusesTest do
  use ExUnit.Case, async: true

  import Plug.Test

  alias TrollWatch.Cache

  @opts TrollWatch.Router.init([])
  @valid_auth_token Application.compile_env!(:troll_watch, :auth_token)
  @invalid_auth_token @valid_auth_token <> "-invalid"

  describe "invalid auth tokens" do
    test "returns 401 when called with missing auth_token" do
      conn =
        :get
        |> conn("/api/statuses")
        |> TrollWatch.Router.call(@opts)

      assert conn.status == 401
    end

    test "returns 401 when called with invalid auth_token" do
      conn =
        :get
        |> conn("/api/statuses", auth_token: @invalid_auth_token)
        |> TrollWatch.Router.call(@opts)

      assert conn.status == 401
    end
  end

  describe "valid auth token" do
    test "returns 200 with json map of statuses" do
      statuses = %{"Bridge 1" => "Available", "Bridge 2" => "Raising soon"}
      expected_response = Jason.encode!(statuses)

      {:ok, _pid} = start_supervised(Cache)

      Cache.set_statuses(statuses)

      conn =
        :get
        |> conn("/api/statuses", auth_token: @valid_auth_token)
        |> TrollWatch.Router.call(@opts)

      assert 200 == conn.status

      assert ["application/json; charset=utf-8"] ==
               Plug.Conn.get_resp_header(conn, "content-type")

      assert expected_response == conn.resp_body
    end
  end

  describe "any other request path with valid auth_token" do
    test "fallsback to 404" do
      conn =
        :get
        |> conn("/api/trolls", auth_token: @valid_auth_token)
        |> TrollWatch.Router.call(@opts)

      assert 404 == conn.status
    end
  end
end
