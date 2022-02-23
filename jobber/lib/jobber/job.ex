defmodule Jobber.Job do
  use GenServer
  require Logger

  defstruct [:work, :id, :max_retries, retries: 0, status: "new"]

  def init(args) do
    work = Keyword.fetch!(args, :work)
    id = Keyword.get(args, :id, random_job_id())
    max_retries = Keyword.get(args, :max_retries, 3)

    state = %Jobber.Job{id: id, work: work, max_retries: max_retries}
    {:ok, state, {:continue, :run}}
  end

  defp random_job_id() do
    :crypto.strong_rand_bytes(5) |> Base.url_encode64(padding: false)
  end
end
