defmodule TrollWatch.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Finch, name: TrollWatch.Finch},
      TrollWatch.Cache,
      TrollWatch.Poller,
      TrollWatch.Router
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TrollWatch.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
