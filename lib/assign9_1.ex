defmodule Assign9_1 do
  @moduledoc false

  defmodule Player do
    defstruct id: nil, collected_marbles: []
  end

  defmodule MarblePool do
    defstruct max_marble_points: 0, current_marble: 0, highest_marble: 0, cursor_location: 0, played_marbles: []

    def new(size) do
      %MarblePool{highest_marble: size}
    end

    def play_move(%MarblePool{current_marble: cm} = marble_pool) do
      {collected_marbles, updated_marble_pool} = update_played_marbles(marble_pool)

      {collected_marbles,%MarblePool{updated_marble_pool | current_marble: cm + 1}}
    end

    def update_played_marbles(%MarblePool{current_marble: 0 = cm, played_marbles: []} = marble_pool) do
      {cm, %MarblePool{marble_pool | played_marbles: [cm]}}
    end

    def update_played_marbles(%MarblePool{current_marble: cm , cursor_location: cl, played_marbles: pm} = mp) when rem(cm, 23) == 0 do
      remove_location = cl - 7
      extracted_marble = Enum.at(pm, remove_location)
      played_marbles = List.delete_at(pm, remove_location)

      {[cm, extracted_marble], %MarblePool{mp | played_marbles: played_marbles, cursor_location: remove_location}}
    end

    def update_played_marbles(%MarblePool{current_marble: cm, cursor_location: cl, played_marbles: pm} = mp) when (cl + 2) > length(pm) do
      IO.inspect("bigger then")
      insert_location = length(pm) - cl
      played_marbles = List.insert_at(pm, insert_location, cm)
      {nil, %MarblePool{mp | played_marbles: played_marbles, cursor_location: insert_location}}
    end

    def update_played_marbles(%MarblePool{current_marble: cm, cursor_location: cl, played_marbles: pm} = mp) do
      IO.inspect("normal")
      insert_location = cl + 2
      played_marbles = List.insert_at(pm, insert_location, cm)
      {nil, %MarblePool{mp | played_marbles: played_marbles, cursor_location: insert_location}}
    end
  end

  defmodule PlayField do
    defstruct marble_pool: nil, players: []

    def new(pool_size, player_count) do
      %__MODULE__{marble_pool: MarblePool.new(pool_size), players: init_players(player_count)}
    end

    def init_players(player_count) do
      Enum.map(1..player_count, &%Player{id: &1})
    end

    def do_move(%PlayField{} = pf) do
      {played_marbles, marble_pool} = MarblePool.play_move(pf.marble_pool)
      {played_marbles, %__MODULE__{pf | marble_pool: marble_pool}}
    end


  end

end
