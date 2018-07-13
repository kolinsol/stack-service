defmodule Stack.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, initial_state) do
    {:ok, _pid} =
      Stack.Supervisor.start_link(Application.get_env(:stack, :initial_state))
  end
end
