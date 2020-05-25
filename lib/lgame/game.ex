defmodule Lgame.Game do
  use GenServer
  alias Lgame.Board

  defstruct id: nil,
            attacker: nil,
            defender: nil

  # CLIENT

  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: ref(id))
  end

  def join(id, player_id, pid), do: try_call(id, {:join, player_id, pid})

  @doc """
  Returns the game's state
  """
  def get_data(id), do: try_call(id, :get_data)

  @doc """
  Returns the game's state for a given player. This means it will
  hide ships positions from the opponent's board.
  """
  def get_data(id, player_id), do: try_call(id, {:get_data, player_id})

  @doc """
  Called when a player leaves the game
  """
  def player_left(id, player_id), do: try_call(id, {:player_left, player_id})

  # SERVER

  def init(id) do
    {:ok, %__MODULE__{id: id}}
  end

  def handle_call({:join, player_id, pid}, _from, game) do
    cond do
      game.attacker != nil and game.defender != nil ->
        {:reply, {:error, "No more players allowed"}, game}

      Enum.member?([game.attacker, game.defender], player_id) ->
        {:reply, {:ok, self}, game}

      true ->
        Process.flag(:trap_exit, true)
        Process.monitor(pid)

        {:ok, board_pid} = create_board(player_id)
        Process.monitor(board_pid)

        game = add_player(game, player_id)

        {:reply, {:ok, self}, game}
    end
  end

  def handle_call(:get_data, _from, game), do: {:reply, game, game}

  def handle_call({:get_data, player_id}, _from, game) do
    game_data = Map.put(game, :my_board, Board.get_data(player_id))

    opponent_id = get_opponents_id(game, player_id)

    if opponent_id != nil do
      game_data = Map.put(game_data, :opponents_board, Board.get_opponents_data(opponent_id))
    end

    {:reply, game_data, game}
  end

  def get_opponents_id(%__MODULE__{attacker: player_id, defender: nil}, player_id), do: nil

  def get_opponents_id(%__MODULE__{attacker: player_id, defender: defender}, player_id),
    do: defender

  def get_opponents_id(%__MODULE__{attacker: attacker, defender: player_id}, player_id),
    do: attacker

  defp create_board(player_id), do: Board.create(player_id)

  defp add_player(%__MODULE__{attacker: nil} = game, player_id), do: %{game | attacker: player_id}
  defp add_player(%__MODULE__{defender: nil} = game, player_id), do: %{game | defender: player_id}
  # ...

  defp ref(id), do: {:global, {:game, id}}

  defp try_call(id, message) do
    case GenServer.whereis(ref(id)) do
      nil ->
        {:error, "Game does not exist"}

      pid ->
        GenServer.call(pid, message)
    end
  end
end
