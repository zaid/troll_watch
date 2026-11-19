defmodule TrollWatch.Cache do
  @moduledoc """
  Simple cache for bridge statuses (using an Agent).
  """

  use Agent

  def start_link(initial_state) do
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  @doc """
  Persists the bridge statuses into the agent cache.
  """
  def set_statuses(statuses) do
    Agent.update(__MODULE__, fn _ -> statuses end)
  end

  @doc """
  Gets the bridge statuses from the agent cache.
  """
  def get_statuses do
    Agent.get(__MODULE__, & &1)
  end
end
