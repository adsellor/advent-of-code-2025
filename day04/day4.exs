defmodule Rolls do
  @type pos :: {integer(), integer()}
  @type grid :: MapSet.t(pos())

  def parse(input) do
    input
    |> String.split()
    |> Enum.with_index()
    |> Enum.flat_map(&parse_line/1)
    |> MapSet.new()
  end

  defp parse_line({line, row}) do
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.filter(fn {char, _} -> char == "@" end)
    |> Enum.map(fn {_, col} -> {row, col} end)
  end

  def neighbors({row, col}) do
    [
      {row - 1, col - 1}, {row - 1, col}, {row - 1, col + 1},
      {row, col - 1},                     {row, col + 1},
      {row + 1, col - 1}, {row + 1, col}, {row + 1, col + 1}
    ]
  end

  def count_neighbors(pos, grid) do
    pos
    |> neighbors()
    |> Enum.count(&MapSet.member?(grid, &1))
  end

  def accessible?(pos, grid) do
    count_neighbors(pos, grid) < 4
  end

  def accessible_rolls(grid) do
    grid
    |> Enum.filter(&accessible?(&1, grid))
    |> MapSet.new()
  end

  def count(grid) do
    grid
    |> accessible_rolls()
    |> MapSet.size()
  end

  def remove(grid, total_removed \\ 0) do
    accessible = accessible_rolls(grid)

    if MapSet.size(accessible) == 0 do
      total_removed
    else
      count = MapSet.size(accessible)
      new_grid = MapSet.difference(grid, accessible)
      remove(new_grid, total_removed + count)
    end
  end

  def solve() do
    "./rolls.txt"
    |> File.read!()
    |> parse()
    |> count()
  end

  def solve2() do
    "./rolls.txt"
    |> File.read!()
    |> parse()
    |> remove()
  end
end

part1 = Rolls.solve()
part2 = Rolls.solve2()

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
