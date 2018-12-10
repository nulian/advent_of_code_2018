defmodule Assign9_1 do
  @moduledoc false

  alias __MODULE__.PlayField

  def assignment do
    line = "data/assign9.data"
    |> File.read!()

    [[player_count, max_point]] = Regex.scan(~r/(\d*) players; last marble is worth (\d*) points/, line, capture: :all_but_first)

    pf = max_point
    |> String.to_integer()
    |> PlayField.new(String.to_integer(player_count))
    |> PlayField.play()


  end

  defmodule Player do
    defstruct id: nil, collected_marbles: []

    def add_collected_marbles(%Player{collected_marbles: cm} = player, collected_marbles) do
      %Player{player | collected_marbles: cm ++ collected_marbles}
    end

    def total_score(%Player{collected_marbles: cm}) do
      Enum.sum(cm)
    end
  end

  defmodule MarblePool do
    defstruct max_marble_points: 0, current_marble: 0, highest_marble: 0, cursor_location: 0, played_marbles: [], total_marbles: 0

    def new(size) do
      %MarblePool{highest_marble: size}
    end

    def play_move(%MarblePool{current_marble: cm} = marble_pool) do
      {collected_marbles, updated_marble_pool} = update_played_marbles(marble_pool)

      {collected_marbles,%MarblePool{updated_marble_pool | current_marble: cm + 1}}
    end

    def update_played_marbles(%MarblePool{current_marble: 0 = cm, played_marbles: []} = marble_pool) do
      {nil, %MarblePool{marble_pool | played_marbles: [cm], total_marbles: 1}}
    end

    def update_played_marbles(%MarblePool{current_marble: cm , cursor_location: cl, played_marbles: pm, total_marbles: tm} = mp) when rem(cm, 23) == 0 do
      remove_location = cl - 7
      extracted_marble = Enum.at(pm, remove_location)
      played_marbles = List.delete_at(pm, remove_location)

      new_index = if remove_location < 0 do
         remove_location + tm
         else
         remove_location
      end
      {[cm, extracted_marble], %MarblePool{mp | played_marbles: played_marbles, cursor_location: new_index, total_marbles: tm - 1}}
    end

    def update_played_marbles(%MarblePool{current_marble: cm, cursor_location: cl, played_marbles: pm, total_marbles: tm} = mp) when (cl + 2) > tm do
      insert_location = tm - cl
      played_marbles = List.insert_at(pm, insert_location, cm)
      {nil, %MarblePool{mp | played_marbles: played_marbles, cursor_location: insert_location, total_marbles: tm + 1}}
    end

    def update_played_marbles(%MarblePool{current_marble: cm, cursor_location: cl, played_marbles: pm, total_marbles: tm} = mp) do
      insert_location = cl + 2
      played_marbles = List.insert_at(pm, insert_location, cm)
      {nil, %MarblePool{mp | played_marbles: played_marbles, cursor_location: insert_location, total_marbles: tm + 1}}
    end
  end

  defmodule PlayField do
    defstruct marble_pool: nil, players: %{}

    def new(pool_size, player_count) do
      %__MODULE__{marble_pool: MarblePool.new(pool_size), players: init_players(player_count)}
    end

    def init_players(player_count) do
      Enum.reduce(1..player_count, %{}, &Map.put(&2, &1, %Player{id: &1}))
    end

    def play(%PlayField{} = pf) do
      pf.players
      |> Stream.cycle()
      |> Enum.reduce_while(pf, fn {id, _}, %PlayField{players: players} = play_field ->
        player = players[id]
        {played_marbles, updated_play_field} = do_move(play_field)
        {cont, updated_players} = if played_marbles do
          {:cont, Map.put(players, id, Player.add_collected_marbles(player, played_marbles))}
        else
          {:cont, players}
        end
       new_cont = if play_field.marble_pool.current_marble == play_field.marble_pool.highest_marble, do: :halt, else: cont
       {new_cont, %PlayField{updated_play_field | players: updated_players}}
      end)
    end

    def do_move(%PlayField{} = pf) do
      {played_marbles, marble_pool} = MarblePool.play_move(pf.marble_pool)
      {played_marbles, %__MODULE__{pf | marble_pool: marble_pool}}
    end

    def calculate_players(%PlayField{players: players}) do
      Enum.reduce(players, %{}, fn {id, player}, acc ->
        Map.put(acc, id, Player.total_score(player))
      end)
    end

    def get_highest_player(%PlayField{} = pf) do
      pf
      |> calculate_players()
      |> Enum.sort(&elem(&1, 1) > elem(&2, 1))
      |> hd()
    end

  end

end
