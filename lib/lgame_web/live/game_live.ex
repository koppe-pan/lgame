defmodule LgameWeb.GameLive do
  use LgameWeb, :live_view
  alias Lgame.GameSupervisor
  alias Lgame.Game

  @impl true
  def mount(%{"game_id" => game_id, "player_id" => player_id}, _session, socket) do
    case Game.join(game_id, player_id, socket.channel_pid) do
      {:ok, pid} ->
        Process.monitor(pid)

        {:ok, assign(socket, :game_id, socket.assigns.game_id)}

      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end
end
