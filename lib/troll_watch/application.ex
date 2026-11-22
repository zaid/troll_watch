defmodule TrollWatch.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TrollWatch.Supervisor]
    Supervisor.start_link(children_for_env(Mix.env()), opts)
  end

  # Private functions
  defp children_for_env(:test), do: []

  defp children_for_env(_env) do
    [
      TrollWatch.Cache,
      TrollWatch.Poller,
      TrollWatch.Router
    ]
  end
end
