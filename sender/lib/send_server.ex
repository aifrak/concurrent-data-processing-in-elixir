defmodule SendServer do
  use GenServer

  def init(args) do
    IO.puts("Received arguments: #{inspect(args)}")
    max_retries = Keyword.get(args, :max_retries, 5)
    state = %{emails: [], max_retries: max_retries}
    {:ok, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:send, email}, state) do
    Sender.send_email(email)
    emails = [%{email: email, status: "sent", retries: 0}] ++ state.emails

    {:noreply, %{state | emails: emails}}
  end
end
