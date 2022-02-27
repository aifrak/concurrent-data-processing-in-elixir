defmodule TicketsTest do
  use ExUnit.Case
  doctest Tickets

  test "greets the world" do
    assert Tickets.hello() == :world
  end
end
