defmodule OnlinePageProducerConsumer do
  use Flow

  def start_link(_args) do
    producers = [Process.whereis(PageProducer)]

    consumers = [
      {Process.whereis(PageConsumerSupervisor), max_demand: 2}
    ]

    Flow.from_stages(producers, max_demand: 1, stages: 2)
    |> Flow.filter(&Scraper.online?/1)
    |> Flow.into_stages(consumers)
  end
end
