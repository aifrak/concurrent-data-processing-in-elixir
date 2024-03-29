defmodule PageConsumerSupervisor do
  use ConsumerSupervisor
  require Logger

  def start_link(_args) do
    ConsumerSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Logger.info("PageConsumerSupervisor init")

    # As we said already, we only need one child spec here.
    # You can think of it as a template, which will be used for all children processes.
    children = [
      %{
        id: PageConsumer,
        start: {PageConsumer, :start_link, []},
        restart: :transient
      }
    ]

    opts = [
      strategy: :one_for_one,
      subscribe_to: []
    ]

    ConsumerSupervisor.init(children, opts)
  end
end
