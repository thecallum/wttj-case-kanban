defmodule Wttj.Indexing do
  @moduledoc """
  Provides functionality for generating ordered indices in a list, allowing for insertion
  of items at any position while maintaining a consistent ordering.
  """

  @doc """
  Generates the next index for inserting an item in a list.

  ## Parameters

  - `previous_display_order`: The index of the item that comes before the insertion point (or nil if inserting at start)
  - `next_display_order`: The index of the item that comes after the insertion point (or nil if inserting at end)

  ## Returns

  Returns a string representing the new index.

  ## Examples

      iex> generate_new_display_order(nil, nil)  # First item
      "1"

      iex> generate_new_display_order(nil, "5.15")  # Insert at start
      "4"

      iex> generate_new_display_order("5.15", nil)  # Insert at end
      "6"

      iex> generate_new_display_order("1", "2")  # Insert between
      "1.5"

  ## Guards

  The function enforces these constraints:
  - previous_display_order must be nil or greater than 0
  - next_display_order must be nil or greater than 0
  - if both indices are present, next_display_order must be greater than previous_display_order
  """

  def generate_new_display_order(previous_display_order, next_display_order)
      when (is_nil(previous_display_order) or previous_display_order > 0) and
             (is_nil(next_display_order) or
                (next_display_order > 0 and
                   (is_nil(previous_display_order) or
                      next_display_order > previous_display_order))) do
    case {previous_display_order, next_display_order} do
      {nil, nil} ->
        {:ok, "1"}

      {nil, next_display_order} ->
        {:ok, get_display_order_top_of_list(next_display_order)}

      {previous_display_order, nil} ->
        {:ok, get_display_order_bottom_of_list(previous_display_order)}

      {previous_display_order, next_display_order} ->
        {:ok, get_midpoint(previous_display_order, next_display_order)}
    end
  end

  defp get_display_order_top_of_list(value) do
    {int_value, _} = Integer.parse(value)

    case int_value == 1 or int_value == 0 do
      true -> get_midpoint("0", value)
      false -> to_string(int_value - 1)
    end
  end

  defp get_display_order_bottom_of_list(value) do
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
