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

    %{"lat" => lat, "lon" => long, "display_name" => display_name} =
      body
      |> Jason.decode!()
      |> List.first()

    {lat, long, display_name}
  end

  def handle_command("latlong" <> location, channel_id) do
    {_status, {_lat, _long, display_name}} =
      Cachex.fetch(:lat_long, String.trim(location), &get_geocode/1)

    Api.create_message(channel_id, "I found '#{display_name}', hopefully that's correct")
  end

  def handle_command("say" <> message, channel_id) do
    Api.create_message(channel_id, message)
  end

  def handle_command(_unknown_command, _channel_id), do: :noop
end
