defmodule SeagullBot do
  use Application
  require Cachex
  require HTTPoison

  def start(_type, _args) do
    HTTPoison.start()

    children = [
      SB.Discord,
      {Cachex, :lat_long}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
