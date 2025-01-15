defmodule Test do
  alias FractionalIndex

  @doc """
  Generates the next index for a given candidate.

  # A, AA, AAA, AAAA
  """
  def generate_index(before_index, after_index) do
    case {before_index, after_index} do
      {nil, nil} ->
        "1"

      {nil, after_value} ->
        get_previous_number(after_value)

      {before_value, nil} ->
        get_next_number(before_value)

      {before_value, after_value} ->
        midpoint(before_value, after_value)
    end
  end

  defp get_previous_number(value) do
    {int_value, _} = Integer.parse(value)

    (int_value - 1)
    |> to_string()
  end

  defp get_next_number(value) do
    {int_value, _} = Integer.parse(value)

    (int_value + 1)
    |> to_string()
  end

  @doc """


  example

  iex(14)> Test.midpoint(4.343, 2)
  {4343.0, 2000.0}


  """
  defp midpoint(a, b) do
    # Convert values to decimal to avoid any floating point errors

    # 1. Count number of decimal places
    most_decimal_points = max(count_decimal_places(a), count_decimal_places(b))

    # 2. Multiply both numbers by this value, so both are decimals
    # eg (4.123, 4.2) -> (4123, 4200)
    multiplier = :math.pow(10, most_decimal_points)

    a = a * multiplier
    b = b * multiplier

    # 3. Calculate the mid point
    # eg 4161.5
    midpoint = (a + b) / 2

    # 4. Divide the midpoint by the previous number of decimal places
    # eg 4.1615
    midpoint / multiplier

    # https://hexdocs.pm/decimal/Decimal.html#module-specifications
    # Im not sure what the precision of decimals are. This could be a problem at some point
    # If this is unavoidable, a reindexing process could be used
  end

  defp count_decimal_places(number) do
    # Counting decimal places is not straight forward
    # So instead, I can check if the string contains a '.',
    ## and count the number of characters after

    number
    |> String.split(".")
    |> case do
      [_, decimals] -> String.length(decimals)
      [_] -> 0
    end
  end
end
