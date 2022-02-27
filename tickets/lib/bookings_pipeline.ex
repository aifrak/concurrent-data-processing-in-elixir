defmodule BookingsPipeline do
  use Broadway

  @producer BroadwayRabbitMQ.Producer

  @producer_config [
    queue: "bookings_queue",
    declare: [durable: true],
    on_failure: :reject_and_requeue,
    connection: [
      host: "rabbitmq"
    ]
  ]

  def start_link(_args) do
    options = [
      name: BookingsPipeline,
      producer: [
        module: {@producer, @producer_config}
        # concurrency: 1
      ],
      processors: [
        default: [
          # concurrency: System.schedulers_online() * 2,
          # min_demand: 5,
          # max_demand: 10
        ]
      ]
    ]

    Broadway.start_link(__MODULE__, options)
  end

  def handle_message(_processor, message, _context) do
    # Add your business logic here...
    IO.inspect(message, label: "Message")
  end
end
