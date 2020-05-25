defmodule Lgame.GameSupervisor do
  use Supervisor
  alias Lgame.{Game}

  def start_link(_opts), do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok) do
    children = [
      Game
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def create_game(id), do: Supervisor.start_child(__MODULE__, [id])

  def current_games do
    __MODULE__
    |> Supervisor.which_children()
    |> Enum.map(&game_data/1)
  end

  defp game_data({_id, pid, _type, _modules}) do
    pid
    |> GenServer.call(:get_data)
    |> Map.take([:id, :attacker, :defender, :turns, :over, :winner])
  end
end
