defmodule RealTimeCollaborationAppWeb.DelayedBroadcaster do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def schedule_broadcast(topic, event, payload, delay_ms) do
    GenServer.cast(__MODULE__, {:schedule, topic, event, payload, delay_ms})
  end

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:schedule, topic, event, payload, delay_ms}, state) do
    Process.send_after(self(), {:broadcast, topic, event, payload}, delay_ms)
    {:noreply, state}
  end

  @impl true
  def handle_info({:broadcast, topic, event, payload}, state) do
    RealTimeCollaborationAppWeb.Endpoint.broadcast!(topic, event, payload)
    {:noreply, state}
  end
end
