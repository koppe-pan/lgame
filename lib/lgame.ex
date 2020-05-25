defmodule Lgame do
  @moduledoc """
  Lgame keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  @id_length Application.get_env(:lgame, :id_length)
  @id_words Application.get_env(:lgame, :id_words)
  @id_number_max Application.get_env(:lgame, :id_number_max)

  @name_number_max Application.get_env(:lgame, :id_number_max)

  @doc """
  Generates unique id for the game
  """
  def generate_player_id do
    @id_length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, @id_length)
  end

  @doc """
  Generates unique id for the game
  """

  def generate_game_id do
    Lgame.Pirate.generate_id(@id_words, @id_number_max)
  end
end
