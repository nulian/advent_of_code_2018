defmodule Assign10 do
  @moduledoc false

  defmodule Point do
    defstruct x: 0, y: 0

    def new(x, y) do
      %__MODULE__{x: x, y: y}
    end
  end

  defmodule Star do
    defstruct position: nil, velocity: nil

    def new(%Point{} = position, %Point{} = velocity) do
      %__MODULE__{position: position, velocity: velocity}
    end

    def apply_velocity(%Star{position: %Point{x: x_pos, y: y_pos}, velocity: %Point{x: x_vel, y: y_vel}} = star) do
      %Star{star | position: %Point{x: x_pos + x_vel, y: y_pos + y_vel}}
    end
  end


  defmodule StarField do
    defstruct stars: [], previous_x_range: nil, seconds: 0

    def move_starfield(%StarField{stars: stars} = starfield) do
      stars = Enum.map(stars, fn star ->
        Star.apply_velocity(star)
      end)

      %StarField{starfield | stars: stars, seconds: starfield.seconds + 1}
    end

    def loop_seconds(starfield) do
      new_starfield = move_starfield(starfield)
      {_, _, {maxx, minx, maxy, miny}} = get_max_size(new_starfield)
      loop_starfield = if (maxx.position.x - minx.position.x) < starfield.previous_x_range do
        loop_seconds(%StarField{new_starfield | previous_x_range: maxx.position.x - minx.position.x})
      else
        starfield
      end

      %StarField{loop_starfield | previous_x_range: maxx.position.x - minx.position.x}
    end

    def get_max_size(starfield) do
      {minx, maxx} = Enum.min_max_by(starfield.stars, fn star ->
        star.position.x
      end)
      {miny, maxy} = Enum.min_max_by(starfield.stars, fn star ->
        star.position.y
      end)
      {xrange, yrange} = {(minx.position.x)..(maxx.position.x), (miny.position.y)..(maxy.position.y)}
      {xrange, yrange, {maxx, minx, maxy, miny}}
    end

    def print_field(starfield) do
      {xrange, yrange, {maxx, _, _, _}} = get_max_size(starfield)

      lookup_map = starfield.stars |> Enum.group_by(& &1.position.y)

      Enum.each(yrange, fn y ->
        Enum.each(xrange, fn x ->
          stars = Map.get(lookup_map, y, [])
          list = stars |> Enum.map(& &1.position.x)
          if Enum.member?(list, x) do
            IO.write("#")
          else
            IO.write(".")
          end

          if x == maxx.position.x do
            IO.write("\n")
          end
        end)
      end)

    end
  end

  def assignment1 do
    points = "data/assign10.data"
    |> File.read!()
    |> String.split("\r\n")

    result = Enum.map(points, fn item ->
      [[p_x, p_y, v_x, v_y]] = Regex.scan(~r/position=<\s*(-?\d*),\s*(-?\d+)> velocity=<\s*(-?\d*),\s*(-?\d*)>/, item, capture: :all_but_first)

      Star.new(Point.new(String.to_integer(p_x), String.to_integer(p_y)), Point.new(String.to_integer(v_x), String.to_integer(v_y)))
    end)

    %StarField{stars: result}
    |> StarField.loop_seconds() |> StarField.print_field
  end

  def assignment2 do
    points = "data/assign10.data"
             |> File.read!()
             |> String.split("\r\n")

    result = Enum.map(points, fn item ->
      [[p_x, p_y, v_x, v_y]] = Regex.scan(~r/position=<\s*(-?\d*),\s*(-?\d+)> velocity=<\s*(-?\d*),\s*(-?\d*)>/, item, capture: :all_but_first)

      Star.new(Point.new(String.to_integer(p_x), String.to_integer(p_y)), Point.new(String.to_integer(v_x), String.to_integer(v_y)))
    end)

    %StarField{stars: result}
    |> StarField.loop_seconds()
    |> Map.get(:seconds)
  end
end
