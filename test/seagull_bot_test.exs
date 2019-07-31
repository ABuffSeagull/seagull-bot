defmodule SeagullBotTest do
  use ExUnit.Case
  doctest SeagullBot

  test "greets the world" do
    assert SeagullBot.hello() == :world
  end
end
