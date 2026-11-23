defmodule TrollWatch.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TrollWatch.Supervisor]
    Supervisor.start_link(children_for_env(get_env()), opts)
  end

  # Private functions
  defp children_for_env(:test), do: []

  defp children_for_env(_env) do
    [
      TrollWatch.Cache,
      TrollWatch.Poller,
      {Bandit, [plug: TrollWatch.Router, port: bandit_port()]}
    ]
  end

  defp get_env do
    Application.get_env(:troll_watch, :env)
  end

  defp bandit_port do
    Application.get_env(:troll_watch, :port)
  end
end
