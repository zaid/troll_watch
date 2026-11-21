defmodule TrollWatch.Client do
  @moduledoc """
  Queries the bridge status page and parses the individual bridge statuses.
  """

  require Logger

  defguardp nonempty_list(elements) when is_list(elements) and elements != []

  @spec get_bridge_statuses() :: map()
  def get_bridge_statuses do
    with {:ok, %{body: body}} <- fetch(),
         {:ok, document} <- extract(body) do
      transform(document)
    end
  end

  # Private functions

  @spec fetch() :: {:ok, Req.Response.t()} | {:error, Exception.t()}
  defp fetch do
    Logger.info("Querying bridge statuses...")

    Req.get(seaway_bridge_status_url())
  end

  @spec extract(response_body :: binary()) :: {:ok, elements :: list()} | {:error, any()}
  defp extract(response_body) do
    with {:ok, document} <- Floki.parse_document(response_body),
         elements when nonempty_list(elements) <-
           Floki.find(document, "table tbody tr tr td:nth-child(2) p") do
      {:ok, elements}
    end
  end

  @spec transform(elements :: list()) :: map()
  defp transform(elements) do
    elements
    |> Enum.map(&Floki.text/1)
    |> Enum.chunk_every(2)
    |> Enum.reduce(%{}, fn [bridge, status], acc ->
      Map.put(acc, String.trim(bridge), String.trim(status))
    end)
  end

  defp seaway_bridge_status_url do
    "https://seaway-greatlakes.com/bridgestatus/detailsnai?key=" <> region()
  end

  defp region do
    "Bridge" <> Application.get_env(:troll_watch, :region)
  end
end
