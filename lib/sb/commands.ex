defmodule SB.Commands do
  alias HTTPoison.Request
  alias HTTPoison.Response
  alias Nostrum.Api
  require Cachex
  require HTTPoison
  require Jason
  require Logger

  defp f_to_c(temp), do: Float.round((temp - 32) * 5 / 9, 2)

  defp mi_to_kilo(distance), do: Float.round(distance * 1.609344, 2)

  defp get_geocode(location) do
    Logger.info("Grabbing new geocode for #{location}")

    {:ok, %Response{body: body}} =
      HTTPoison.request(%Request{
        method: :get,
        url: "https://nominatim.openstreetmap.org/search",
        params: [format: "jsonv2", q: location]
      })

    result = Jason.decode!(body)

    case result do
      [] ->
        {:ignore, nil}

      _ ->
        %{"lat" => lat, "lon" => long, "display_name" => display_name} = List.first(result)

        {lat, long, display_name}
    end
  end

  def handle_command("find" <> location, channel_id) do
    message =
      case Cachex.fetch(:lat_long, String.trim(location), &get_geocode/1) do
        {:ignore, nil} ->
          "According to my records, that place doesn't exist"

        {_, {_lat, _long, display_name}} ->
          "I found '#{display_name}', hopefully that's correct"
      end

    Api.create_message(channel_id, message)
  end

  def handle_command("weather" <> location, channel_id) do
    message =
      case Cachex.fetch(:lat_long, String.trim(location), &get_geocode/1) do
        {:ignore, nil} ->
          "Can't find that location"

        {_, {lat, lng, display_name}} ->
          %{"currently" => currently, "hourly" => hourly} =
            HTTPoison.request!(
              :get,
              "https://api.darksky.net/forecast/#{Application.fetch_env!(:seagull_bot, :token)}/#{
                lat
              },#{lng}"
            )
            |> Map.get(:body)
            |> Jason.decode!()

          temp = Map.get(currently, "apparentTemperature")
          wind_speed = Map.get(currently, "windSpeed")

          ">>> __#{display_name}__

**Feels like: #{temp}F / #{f_to_c(temp)}C**
*Humidity: #{round(Map.get(currently, "humidity") * 100)}%*
*Wind Speed: #{wind_speed} mph / #{mi_to_kilo(wind_speed)} kph*

Today: #{Map.get(hourly, "summary")}"
      end

    Api.create_message(channel_id, message)
  end

  def handle_command("say" <> message, channel_id) do
    Api.create_message(channel_id, message)
  end

  def handle_command(_unknown_command, _channel_id), do: :noop
end
