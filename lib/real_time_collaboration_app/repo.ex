defmodule RealTimeCollaborationApp.Repo do
  use Ecto.Repo,
    otp_app: :real_time_collaboration_app,
    adapter: Ecto.Adapters.Postgres
end
