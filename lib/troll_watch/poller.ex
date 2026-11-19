defmodule TrollWatch.Poller do
  @moduledoc """
  A simple poller which invokes the client on a fixed interval and
  updates the cached values.
  """

  use GenServer

  alias TrollWatch.Cache
  alias TrollWatch.Client

  @default_polling_interval 60_000

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(opts) do
    {:ok, opts, {:continue, :invoke_client}}
  end

  # Callbacks

  @impl GenServer
  def handle_continue(:invoke_client, state) do
    polling_interval = Keyword.get(state, :polling_interval, @default_polling_interval)

    fetch_and_persist_bridge_statuses()

    {:noreply, [polling_interval: polling_interval], polling_interval}
  end

  @impl GenServer
  def handle_info(:timeout, state) do
    polling_interval = Keyword.get(state, :polling_interval)

    fetch_and_persist_bridge_statuses()

    {:noreply, state, polling_interval}
  end

  # Private functions

  defp fetch_and_persist_bridge_statuses do
    Client.get_bridge_statuses()
    |> Cache.set_statuses()
  end
end
