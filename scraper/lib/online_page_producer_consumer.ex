defmodule OnlinePageProducerConsumer do
  use GenStage
  require Logger

  def start_link(_args) do
    initial_state = []
    GenStage.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def init(initial_state) do
    Logger.info("OnlinePageProducerConsumer init")

    subscription = [
      {PageProducer, min_demand: 0, max_demand: 1}
    ]

    {:producer_consumer, initial_state, subscribe_to: subscription}
  end

  def handle_events(events, _from, state) do
    Logger.info("OnlinePageProducerConsumer received #{inspect(events)}")
    events = Enum.filter(events, &Scraper.online?/1)
    {:noreply, events, state}
  end
end
