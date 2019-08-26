defmodule SB.Commands do
  alias HTTPoison.Request
  alias HTTPoison.Response
  alias Nostrum.Api
  require Cachex
  require HTTPoison
  require Jason
  require Logger

  defp get_geocode(location) do
    Logger.info("Grabbing new geocode for #{location}")

    {:ok, %Response{body: body}} =
      HTTPoison.request(%Request{
        method: :get,
        url: "https://nominatim.openstreetmap.org/search",
        params: [format: "jsonv2", q: location]
      })
      |> IO.inspect()

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
        {:commit, {_lat, _long, display_name}} ->
          "I found '#{display_name}', hopefully that's correct"

        {:ignore, nil} ->
          "According to my records, that place doesn't exist"
      end

    Api.create_message(channel_id, message)
  end

  def handle_command("say" <> message, channel_id) do
    Api.create_message(channel_id, message)
  end

  def handle_command(_unknown_command, _channel_id), do: :noop
end
