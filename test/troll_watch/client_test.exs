defmodule TrollWatch.ClientTest do
  use ExUnit.Case, async: true

  alias TrollWatch.Client

  @valid_bridge_status_response "test/support/fixtures/valid_sct_response.html"

  describe "when remote service returns 200" do
    test "returns [] when bridge status information is missing" do
      Req.Test.stub(Client, fn conn ->
        Req.Test.html(conn, "<table><tbody><tr><td></td></tr></tbody></table>")
      end)

      assert [] == Client.get_bridge_statuses()
    end

    test "returns map of bridge statuses if present" do
      html = File.read!(@valid_bridge_status_response)

      Req.Test.stub(Client, fn conn ->
        Req.Test.html(conn, html)
      end)

      assert %{
               "Carlton St. (Bridge 3A)" => "Available",
               "Glendale Ave. (Bridge 5)" => "Available",
               "Highway 20 (Bridge 11)" => "Available",
               "Lakeshore Rd (Bridge 1)" => "Available (raising soon)",
               "Queenston St. (Bridge 4)" => "Available"
             } == Client.get_bridge_statuses()
    end
  end

  describe "when remote service returns an error" do
    test "returns {:error, reason} for 404s" do
      Req.Test.stub(Client, fn conn ->
        Plug.Conn.send_resp(conn, :not_found, "page not found")
      end)

      assert match?({:error, %Req.Response{status: 404}}, Client.get_bridge_statuses())
    end

    test "returns {:error, reason} for 500s" do
      Req.Test.stub(Client, fn conn ->
        Plug.Conn.send_resp(conn, 503, "something went wrong")
      end)

      assert match?(
               {:error, %Req.Response{body: "something went wrong"}},
               Client.get_bridge_statuses()
             )
    end

    test "returns {:error, timeout} for timeouts" do
      Req.Test.stub(Client, fn conn ->
        Req.Test.transport_error(conn, :timeout)
      end)

      assert match?({:error, %Req.TransportError{reason: :timeout}}, Client.get_bridge_statuses())
    end
  end
end
