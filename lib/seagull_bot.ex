defmodule SeagullBot do
  use Application

  def start(_type, _args) do
    children = [
      SB.Discord
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
