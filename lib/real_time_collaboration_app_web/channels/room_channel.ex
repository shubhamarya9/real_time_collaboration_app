defmodule RealTimeCollaborationAppWeb.RoomChannel do
  use RealTimeCollaborationAppWeb, :channel

  @impl true
  def join("room:lobby", payload, socket) do
    if authorized?(payload) do
      IO.inspect("User successfully joined room:lobby, sending :after_join message", label: "DEBUG")
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end


  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    IO.inspect "Received message from #{socket.topic} by #{socket.assigns.user_id} and the message is #{payload["name"]}"
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast!(socket, "shout", payload)
    {:noreply, socket}
  end
  @impl true
  def handle_info(:after_join, socket) do
    IO.inspect("handle_info triggered!", label: "DEBUG BEFORE BROADCAST")

    RealTimeCollaborationAppWeb.Endpoint.broadcast!(
      "room:lobby",
      "user_joined",
      %{message: "A new user has joined"}
    )

    IO.inspect("Broadcast finished", label: "DEBUG AFTER BROADCAST")

    {:noreply, socket}
  end



  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
