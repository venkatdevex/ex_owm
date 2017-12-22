defmodule ExOwm.RequestString.CurrentWeather do

  # @todo:
  # 1. Add validation for add_prefix_substring/2 params.

  def build_request_string(location, opts) do
    {location, opts}
    |> add_prefix_substring()
    |> add_location_substring()
    |> add_search_accuracy_substring()
    |> add_units_substring()
    |> add_language_substring()
    |> add_api_key_substring()
  end

  # Start building querys string.
  defp add_prefix_substring({location, opts}) do
    {"api.openweathermap.org/data/2.5/weather", location, opts}
  end

  # Add location type to query string.
  defp add_location_substring({string, %{city: city}, opts}),
    do: {string <> "?q=#{city}", opts}

  defp add_location_substring({string, %{city: city, country_code: country_code}, opts}),
    do: {string <> "?q=#{city},#{country_code}", opts}

  defp add_location_substring({string, %{id: id}, opts}),
    do: {string <> "?id=#{id}", opts}

  defp add_location_substring({string, %{lat: lat, lon: lon}, opts}),
    do: {string <> "?lat=#{lat}&lon=#{lon}", opts}

  defp add_location_substring({string, %{zip: zip, country_code: country_code}, opts}),
    do: {string <> "?zip=#{zip},#{country_code}", opts}

  defp add_search_accuracy_substring({string, opts}) do
    case Keyword.get(opts, :type) do
      :like -> {string <> "&type=like", opts}
      :accurate -> {string <> "&type=accurate", opts}
      _     -> {string, opts}
    end
  end

  # Add temperature type to query string. Lack of this part make api to return default
  # temperature in Kelvins.
  defp add_units_substring({string, opts}) do
    case Keyword.get(opts, :units) do
      :metric   -> {string <> "&units=metric", opts}
      :imperial -> {string <> "&units=imperial", opts}
      _         -> {string, opts}
    end
  end

  defp add_language_substring({string, opts}) do
    case Keyword.has_key?(opts, :lang) do
      true ->
        lang =
          Keyword.get(opts, :lang)
          |> Atom.to_string()
        string <> "&lang=#{lang}"
      false ->
        string
    end
  end

  defp add_api_key_substring(string), do: string <> "&APPID=#{Application.get_env(:ex_owm, :api_key)}"
end
