defmodule Wttj.Indexing do
  @moduledoc """
  Functions for generating a new `displayOrder` value.
  """

  @doc """
  Generates the next `displayOrder` value for when moving a candidate to a different position/column.

  ## Parameters

  - `previous_display_order`: The `displayOrder` value of the candidate before insertion point (or nil)
  - `next_display_order`: The `displayOrder` value of the candidate after insertion point (or nil)

  ## Examples

      iex> generate_new_display_order(nil, nil)  # First item
      "1"

      iex> generate_new_display_order(nil, "5.15")  # Insert at start
      "4"

      iex> generate_new_display_order("5.15", nil)  # Insert at end
      "6"

      iex> generate_new_display_order("1", "2")  # Insert between
      "1.5"
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

  defp get_midpoint(a, b) do
    # Finds the midpoint between two floats
    # The idea was, by converting the floats to decimals, it would avoid floating point rounding errors
    # But testing has proven that this isnt the case. You will still get rounding errors
    # This method needs a way to handle floating point rounding errors

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

  defp count_decimal_places(number) do
    # Counts the number of decimal places in a float. For example "1.234 => 3"
    number
    |> String.split(".")
    |> case do
      [_, decimals] -> String.length(decimals)
      [_] -> 0
    end
  end
end
