defmodule Wttj.Indexing do
   @moduledoc """
  Provides functionality for generating ordered indices in a list, allowing for insertion
  of items at any position while maintaining a consistent ordering.
  """

  @doc """
  Generates the next index for inserting an item in a list.

  ## Parameters

  - `before_index`: The index of the item that comes before the insertion point (or nil if inserting at start)
  - `after_index`: The index of the item that comes after the insertion point (or nil if inserting at end)

  ## Returns

  Returns a string representing the new index.

  ## Examples

      iex> generate_index(nil, nil)  # First item
      "1"

      iex> generate_index(nil, "5.15")  # Insert at start
      "4"

      iex> generate_index("5.15", nil)  # Insert at end
      "6"

      iex> generate_index("1", "2")  # Insert between
      "1.5"

  ## Guards

  The function enforces these constraints:
  - before_index must be nil or greater than 0
  - after_index must be nil or greater than 0
  - if both indices are present, after_index must be greater than before_index
  """

  def generate_index(before_index, after_index)
      when (is_nil(before_index) or before_index > 0) and
             (is_nil(after_index) or
                (after_index > 0 and (is_nil(before_index) or after_index > before_index))) do

    case {before_index, after_index} do
      {nil, nil} ->
        "1"

      {nil, after_value} ->
        get_previous_number(after_value)

      {before_value, nil} ->
        get_next_number(before_value)

      {before_value, after_value} ->
        get_midpoint(before_value, after_value)
    end
  end

  defp get_previous_number(value) do
    {int_value, _} = Integer.parse(value)

    case int_value == 1 or int_value == 0 do
      true -> get_midpoint("0", value)
      false -> to_string(int_value - 1)
    end
  end

  defp get_next_number(value) do
    {int_value, _} = Integer.parse(value)

    (int_value + 1)
    |> to_string()
  end

  defp parse_num(value) do
    case String.contains?(value, ".") do
      true ->
        String.to_float(value)

      false ->
        {num, _} = Integer.parse(value)
        num * 1.0
    end
  end

  @doc """
  Gets the midpoint between two numbers while handling decimal places accurately.

  The function handles decimal precision by:
  1. Converting both numbers to integers
  2. Calculating the midpoint of the integers
  3. Converting back to the original decimal precision

  Note: There may be precision limitations based on Decimal specifications.
  If precision issues arise, a reindexing process could be implemented.

  See: https://hexdocs.pm/decimal/Decimal.html#module-specifications
  """
  defp get_midpoint(a, b) do
    most_decimal_points = max(count_decimal_places(a), count_decimal_places(b))

    multiplier =
      :math.pow(10, most_decimal_points)
      |> max(1)

    a = parse_num(a) * multiplier
    b = parse_num(b) * multiplier

    get_midpoint = (a + b) / 2

    (get_midpoint / multiplier)
    |> to_string()
  end

  @doc """
  Counts the number of decimal places in a number.

  Handles the edge cases by:
  - Splitting the string on decimal point
  - If there's a decimal part, returns its length
  - If there's no decimal part, returns 0
  """
  defp count_decimal_places(number) do
    number
    |> String.split(".")
    |> case do
      [_, decimals] -> String.length(decimals)
      [_] -> 0
    end
  end
end
