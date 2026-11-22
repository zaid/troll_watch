defmodule TrollWatch.PollerTest do
  use ExUnit.Case, async: false

  alias TrollWatch.Cache, as: Cache
  alias TrollWatch.Poller

  @html File.read!("test/support/fixtures/valid_sct_response.html")

  setup do
    {:ok, pid} = start_supervised(Cache)

    %{cache_pid: pid}
  end

  describe "initialization" do
    test "persists statuses in cache" do
      Req.Test.stub(TrollWatch.Client, fn conn ->
        Req.Test.html(conn, @html)
      end)

      Req.Test.allow(TrollWatch.Client, self(), fn ->
        Process.whereis(Poller)
      end)

      {:ok, pid} = start_supervised(Poller)

      :sys.get_state(pid)

      assert %{
               "Carlton St. (Bridge 3A)" => "Available",
               "Glendale Ave. (Bridge 5)" => "Available",
               "Highway 20 (Bridge 11)" => "Available",
               "Lakeshore Rd (Bridge 1)" => "Available (raising soon)",
               "Queenston St. (Bridge 4)" => "Available"
             } == Cache.get_statuses()
    end

    test "defaults to 60 seconds polling" do
      Req.Test.stub(TrollWatch.Client, fn conn ->
        Req.Test.html(conn, @html)
      end)

      Req.Test.allow(TrollWatch.Client, self(), fn ->
        Process.whereis(Poller)
      end)

      {:ok, pid} = start_supervised(Poller)

      state = :sys.get_state(pid)

      assert 60_000 == Keyword.get(state, :polling_interval)
    end
  end

  describe "callbacks" do
    test "timeout callback triggers new statuses to be stored" do
      Req.Test.expect(TrollWatch.Client, fn conn ->
        Req.Test.html(conn, @html)
      end)

      Req.Test.expect(TrollWatch.Client, fn conn ->
        updated_html = String.replace(@html, "(Bridge 1)", "(Bridge 42)")
        Req.Test.html(conn, updated_html)
      end)

      Req.Test.allow(TrollWatch.Client, self(), fn ->
        Process.whereis(Poller)
      end)

      {:ok, pid} = start_supervised({Poller, polling_interval: 60_000})

      :sys.get_state(pid)

      assert Cache.get_statuses() == %{
               "Carlton St. (Bridge 3A)" => "Available",
               "Glendale Ave. (Bridge 5)" => "Available",
               "Highway 20 (Bridge 11)" => "Available",
               "Lakeshore Rd (Bridge 1)" => "Available (raising soon)",
               "Queenston St. (Bridge 4)" => "Available"
             }

      send(pid, :timeout)
      :sys.get_state(pid)

      assert Cache.get_statuses() == %{
               "Carlton St. (Bridge 3A)" => "Available",
               "Glendale Ave. (Bridge 5)" => "Available",
               "Highway 20 (Bridge 11)" => "Available",
               "Lakeshore Rd (Bridge 42)" => "Available (raising soon)",
               "Queenston St. (Bridge 4)" => "Available"
             }
    end
  end
end
