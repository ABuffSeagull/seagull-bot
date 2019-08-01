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
        {:MESSAGE_CREATE, {%Message{content: "!" <> command, channel_id: channel_id}}, _ws_state}
      ) do
    # IO.inspect(message, label: "Message")
    SB.Commands.handle_command(command, channel_id)
  end

  def handle_event(_event) do
    # IO.inspect(data, label: "Etc")
    :noop
  end
end
