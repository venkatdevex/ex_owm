defmodule ExOwm do
  alias ExOwm.Feature.Coordinator
  require Logger
  use Application
  @moduledoc """
  Documentation for ExOwm, OpenWeatherMap API Elixir client.
  """

  def start(_type, _args) do
    import Supervisor.Spec
    Logger.info "Starting supervision tree for #{inspect(__MODULE__)}"

    children = [
      supervisor(ExOwm.Feature.Supervisor, [])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  @typedoc """
  Current weather data API request.
  """
  @type request ::
    %{city: String.t} | %{city: String.t, country_code: String.t} |
    %{id: integer()} | 
    %{lat: float(), lon: float()} |
    %{zip: String.t, country_code: String.t}

  @typedoc """
  Current weather data API requests.
  """
  @type requests :: [request]

  @typedoc """
  Current weather data API call available options.
  """
  @type option :: :format | :units | :lang

  @typedoc """
  Keyword list of options
  """
  @type options :: [option: term]

  @doc """
  Gets weather data of the given location with specified options.

  ## Examples

      iex> is_list ExOwm.get_current_weather_data([%{city: "Warsaw"}, %{city: "London", country_code: "uk"}], units: :metric, lang: :pl)
      true 
      iex> is_list ExOwm.get_current_weather_data([%{id: 2759794}], units: :metric, lang: :nl)
      true

  """
  @spec get_current_weather_data([request], options) :: map
  def get_current_weather_data(locations, opts \\ []) when is_list(locations) do
    Coordinator.start_workers(locations, opts)
    Coordinator.get_state()
  end

end
