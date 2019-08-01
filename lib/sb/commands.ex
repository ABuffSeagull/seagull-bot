defmodule SB.Commands do
  alias Nostrum.Api

  def handle_command("say" <> message, channel_id) do
    Api.create_message(channel_id, message)
  end
end
