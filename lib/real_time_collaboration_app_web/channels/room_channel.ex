defmodule RealTimeCollaborationAppWeb.RoomChannel do
  use RealTimeCollaborationAppWeb, :channel
  use Timex

  @required_general_fields ["type", "change_id", "position"]
  @required_edit_fields ["length"]
  @required_format_fields ["style"]

  @impl true
  def join("room:lobby", payload, socket) do
    if authorized?(payload) do
      # Add detailed socket inspection
      IO.inspect(socket, label: "DEBUG: Socket at join")

      # Ensure socket has proper topic assignment
      socket = assign(socket, :topic, "room:lobby")
      IO.inspect("User successfully joined room:lobby", label: "DEBUG")

      # Test the broadcast functionality immediately
      test_payload = %{"type" => "test", "position" => 0, "change_id" => Ecto.UUID.generate()}
      RealTimeCollaborationAppWeb.Endpoint.broadcast!("room:lobby", "test_message", test_payload)
      IO.puts("DEBUG: Test broadcast sent")

      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_in("shout", payload, socket) do
    IO.inspect(payload, label: "DEBUG: Received Payload")

    if check_payload(payload) do
      IO.puts("✅ Payload is valid!")

      change_id = Ecto.UUID.generate()
      timestamp = Timex.now() |> Timex.format!("{ISO:Extended}")

      updated_payload =
        payload
        |> Map.put("change_id", change_id)
        |> Map.put("timestamp", timestamp)

      # Use the DelayedBroadcaster
      RealTimeCollaborationAppWeb.DelayedBroadcaster.schedule_broadcast(
        "room:lobby",
        "message",
        updated_payload,
        1500
      )

      IO.puts("DEBUG: Scheduled delayed broadcast via DelayedBroadcaster")
      {:noreply, socket}
    else
      IO.puts("❌ Invalid payload!")
      {:reply, {:error, "Invalid payload"}, socket}
    end
  end

  # Catch-all handler for debugging purposes
  @impl true
  def handle_info(msg, socket) do
    IO.inspect(msg, label: "DEBUG: Received unknown message")
    {:noreply, socket}
  end

  def check_payload(%{"type" => type, "position" => position} = payload) do
    required_fields =
      case type do
        "insert" -> @required_general_fields
        "delete" -> @required_general_fields ++ @required_edit_fields
        "update" -> @required_general_fields ++ @required_edit_fields
        "format" -> @required_general_fields ++ @required_format_fields ++ @required_edit_fields
        _ -> nil
      end

    # Ensure required fields exist
    valid_fields = required_fields && Enum.all?(required_fields, &Map.has_key?(payload, &1))

    # Type validation (only check if the field exists)
    valid_types =
      is_integer(position) and position >= 0 and
      (not Map.has_key?(payload, "text") or is_binary(payload["text"])) and
      (not Map.has_key?(payload, "length") or (is_integer(payload["length"]) and payload["length"] > 0)) and
      (not Map.has_key?(payload, "style") or is_binary(payload["style"]))

    valid_fields and valid_types
  end

  def check_payload(_) do
    false
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
