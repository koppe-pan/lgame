defmodule LgameWeb.PageLive do
  use LgameWeb, :live_view
  alias Lgame.GameSupervisor

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, game_id: "", player_id: "")}
  end

  @impl true
  def handle_event("new_game", _value, socket) do
    game_id = Lgame.generate_game_id()
    GameSupervisor.create_game(game_id)

    socket
    |> put_flash(:info, "game created")

    {:noreply, assign(socket, game_id: game_id)}
  end

  @impl true
  def handle_event("join_game", %{"game_id" => game_id} = _value, socket) do
    player_id = Lgame.generate_player_id()

    socket
    |> put_flash(:info, "game created")

    {:noreply,
     push_redirect(socket,
       to: Routes.game_path(socket, :index, %{"game_id" => game_id, "player_id" => player_id})
     )}
  end

  @impl true
  def handle_event("suggest", %{"q" => query}, socket) do
    {:noreply, assign(socket, results: search(query), query: query)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    case search(query) do
      %{^query => vsn} ->
        {:noreply, redirect(socket, external: "https://hexdocs.pm/#{query}/#{vsn}")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "No dependencies found matching \"#{query}\"")
         |> assign(results: %{}, query: query)}
    end
  end

  defp search(query) do
    if not LgameWeb.Endpoint.config(:code_reloader) do
      raise "action disabled when not in development"
    end

    for {app, desc, vsn} <- Application.started_applications(),
        app = to_string(app),
        String.starts_with?(app, query) and not List.starts_with?(desc, ~c"ERTS"),
        into: %{},
        do: {app, vsn}
  end
end
