defmodule Assign9_2 do
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
    |> PlayField.get_highest_player()

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

  defmodule LinkedList do
    defstruct previous_marbles: [], next_marbles: []

    def add_item(%LinkedList{next_marbles: marbles} = ll, marble) do
      %LinkedList{ ll | next_marbles: [marble | marbles]}
    end

    def remove_current_item(%LinkedList{next_marbles: [head | rest]} = ll) do
      {head, %LinkedList{ll | next_marbles: rest}}
    end

    def move_list(linked_list, 0), do: linked_list

    def move_list(%LinkedList{previous_marbles: pm, next_marbles: []}, amount) when amount > 0 do
      move_list(%LinkedList{next_marbles: Enum.reverse(pm)}, amount)
    end

    def move_list(%LinkedList{previous_marbles: pm, next_marbles: [head | rest]}, amount) when amount > 0 do
      move_list(%LinkedList{previous_marbles: [head | pm], next_marbles: rest}, amount - 1)
    end

    def move_list(%LinkedList{previous_marbles: [], next_marbles: nm}, amount) when amount < 0 do
      move_list(%LinkedList{previous_marbles: Enum.reverse(nm)}, amount)
    end

    def move_list(%LinkedList{previous_marbles: [head | rest], next_marbles: nm}, amount) when amount < 0 do
      move_list(%LinkedList{previous_marbles: rest, next_marbles: [head | nm]}, amount + 1)
    end
  end

  defmodule MarblePool do
    defstruct max_marble_points: 0, current_marble: 0, marble_list: %LinkedList{}, highest_marble: 0, total_marbles: 0

    def new(size) do
      %MarblePool{highest_marble: size}
    end

    def play_move(%MarblePool{current_marble: cm} = marble_pool) do
      {collected_marbles, updated_marble_pool} = update_played_marbles(marble_pool)

      {collected_marbles,%MarblePool{updated_marble_pool | current_marble: cm + 1}}
    end

    def update_played_marbles(%MarblePool{current_marble: 0 = cm, total_marbles: 0, marble_list: ml} = marble_pool) do
      {nil, %MarblePool{marble_pool | marble_list: LinkedList.add_item(ml, cm), total_marbles: 1}}
    end

    def update_played_marbles(%MarblePool{current_marble: cm , marble_list: ml, total_marbles: tm} = mp) when rem(cm, 23) == 0 do

      {marble, marble_list} = ml
      |> LinkedList.move_list( -7)
      |> LinkedList.remove_current_item()
      {[cm, marble], %MarblePool{mp | marble_list: marble_list, total_marbles: tm - 1}}
    end

    def update_played_marbles(%MarblePool{current_marble: cm, marble_list: ml, total_marbles: tm} = mp) do
      updated_list = ml
      |> LinkedList.move_list(2)
      |> LinkedList.add_item(cm)
      {nil, %MarblePool{mp | marble_list: updated_list, total_marbles: tm + 1}}
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
