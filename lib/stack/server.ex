defmodule Stack.Server do
  use GenServer

  def start_link(stash_pid) do
    GenServer.start_link(__MODULE__, stash_pid, name: __MODULE__)
  end

  def init(stash_pid) do
    current_state = Stack.Stash.get_value stash_pid
    {:ok, {current_state, stash_pid}}
  end

  def terminate(_reason, {current_state, stash_pid}) do
    Stack.Stash.save_value stash_pid, current_state
  end

  def state do
    GenServer.call(__MODULE__, :state)
  end

  def pop do
    GenServer.call(__MODULE__, :pop)
  end

  def push(val) do
    GenServer.cast(__MODULE__, {:push, val})
  end

  def die do
    GenServer.call(__MODULE__, :die)
  end

  def handle_call(:pop, _from, {[h|t], stash_pid}) do
    {:reply, h, {t, stash_pid}}
  end
  def handle_call(:state, _from, {state, stash_pid}) do
    {:reply, state, {state, stash_pid}}
  end
  def handle_call(:die, _from, {_,_}) do
    exit(:boom)
  end

  def handle_cast({:push, val}, {state, stash_pid}) do
    {:noreply, {[val|state], stash_pid}}
  end
end
