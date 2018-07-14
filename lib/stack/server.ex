defmodule Stack.Server do
  use GenServer

  require Logger

  @vsn "1"

  defmodule State do
    defstruct content: [], size: 0, history: [], stash_pid: nil
  end

  def start_link(stash_pid) do
    GenServer.start_link(__MODULE__, stash_pid, name: __MODULE__)
  end

  def init(stash_pid) do
    {content, history} = Stack.Stash.get_value stash_pid
    {:ok, %State{
      content: content,
      size: length(content),
      history: history,
      stash_pid: stash_pid
    }}
  end

  def terminate(_reason, state) do
    Stack.Stash.save_value state.stash_pid, {state.content, state.history}
  end

  def content do
    GenServer.call(__MODULE__, :content)
  end

  def size do
    GenServer.call(__MODULE__, :size)
  end

  def history do
    GenServer.call(__MODULE__, :history)
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

  def handle_call(:pop, _from, %State{content: [h|t]} = state) do
    {:reply, h, %{state |
      content: t,
      history: [{:pop, h}|state.history],
      size: state.size - 1
    }}
  end

  def handle_call(:content, _from, state) do
    {:reply, state.content, state}
  end

  def handle_call(:size, _from, state) do
    {:reply, state.size, state}
  end

  def handle_call(:history, _form, state) do
    {:reply, state.history, state}
  end

  def handle_call(:die, _from, _state) do
    exit(:boom)
  end

  def handle_cast({:push, val}, state) do
    {:noreply, %{state |
      content: [val|state.content],
      history: [{:push, val}|state.history],
      size: state.size + 1
    }}
  end

  def code_change("0", old_state = {curent_state, stash_pid}, _extra) do
    new_state = %State{
      content: curent_state,
      stash_pid: stash_pid,
      size: length(curent_state)
    }
    Logger.info "trandsorming state"
    Logger.info inspect(old_state)
    Logger.info inspect(new_state)
    {:ok, new_state}
  end
end
