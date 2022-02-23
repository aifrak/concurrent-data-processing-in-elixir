defmodule Jobber do
  @moduledoc """
  Documentation for `Jobber`.
  """

  alias Jobber.{JobRunner, JobSupervisor}

  @doc """
  Hello world.

  ## Examples

      iex> Jobber.hello()
      :world

  """
  def hello do
    :world
  end

  def start_job(args) do
    DynamicSupervisor.start_child(JobRunner, {JobSupervisor, args})
  end
end
