defmodule Sender do
  @moduledoc """
  Documentation for `Sender`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Sender.hello()
      :world

  """
  def hello do
    :world
  end

  def send_email(email) do
    Process.sleep(3000)
    IO.puts("Email to #{email} sent")
    {:ok, "email_sent"}
  end

  def notify_all(emails) do
    Enum.each(emails, fn email ->
      Task.start(fn ->
        send_email(email)
      end)
    end)
  end
end
