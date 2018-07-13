defmodule Stack.Stash do
  use GenServer

  def start_link(current_value) do
    {:ok, pid} = GenServer.start_link(__MODULE__, current_value)
  end

  def get_value(pid) do
    GenServer.call(pid, :get_value)
  end

  def save_value(pid, value) do
    GenServer.cast(pid, {:save_value, value})
  end

  def die(pid) do
    GenServer.call(pid, :die)
  end

  def handle_call(:get_value, _from, current_value) do
    {:reply, current_value, current_value}
  end
  def handle_call(:die, _from, state) do
    exit(:boom)
  end

  def handle_cast({:save_value, value}, current_value) do
    {:noreply, value}
  end
end
