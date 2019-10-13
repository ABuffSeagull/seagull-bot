defmodule SB.Discord do
  use Nostrum.Consumer
  require Logger
  alias Nostrum.Struct.Message

  def start_link do
    Logger.info("Starting up...")
    Consumer.start_link(__MODULE__, name: SB.Discord)
  end

  def handle_event({:READY, _data, _ws_state}), do: Logger.info("Logged in!")

  def handle_event(
        {:MESSAGE_CREATE, %Message{content: message, channel_id: channel_id}, _ws_state}
      ),
      do: handle_message(message, channel_id)

  def handle_event(_event) do
    # IO.inspect(event, label: "Etc")
  end

  def handle_message("!" <> command, channel_id),
    do: SB.Commands.handle_command(command, channel_id)

  def handle_message("Thank" <> rest, channel_id),
    do: SB.Commands.say_thanks(rest, channel_id, true)

  def handle_message("thank" <> rest, channel_id),
    do: SB.Commands.say_thanks(rest, channel_id, false)

  def handle_message(message, channel_id), do: SB.Commands.extra_checks(message, channel_id)
end
