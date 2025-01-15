defmodule Wttj.OrderingTest do
  use ExUnit.Case
  alias Test

  describe "when both indicies are nil" do
    test "returns '1' as this is the first item" do
      # Act
      result = Test.generate_index(nil, nil)

      # Assert
      assert result == "1"
    end
  end

  describe "when the first index is nil" do
    @test_data [
      {"5.15", "4"},
      {"3.545", "2"},
      {"300.545", "299"},
      {"1", "0.5"},
      {"0.1", "0.05"}
    ]

    for {input, expected} <- @test_data do
      test "returns #{expected} when the input is #{input}" do
        # Act
        result = Test.generate_index(nil, unquote(input))

        # Assert
        assert result == unquote(expected)
      end
    end
  end

  describe "when the last index is nil" do
    @test_data [
      {"5.15", "6"},
      {"3.545", "4"},
      {"300.545", "301"},
      {"1", "2"},
      {"0.1", "1"}
    ]

    for {input, expected} <- @test_data do
      test "returns #{expected} next integer" do
        # Act
        result = Test.generate_index(unquote(input), nil)

        # Assert
        assert result == unquote(expected)
      end
    end
  end

  describe "when both indicies provided" do
    @test_data [
      {"1", "2", "1.5"},
      {"0.1", "2", "1.05"},
      {"5.4", "8.445", "6.9225"},
      {"3.7", "9.3", "6.5"},
      {"0.25", "4.75", "2.5"},
      {"6.8", "7.2", "7.0"},
      {"10.5", "15.5", "13.0"},
      {"2.4", "8.6", "5.5"},
      {"0.8", "1.6", "1.2"},
      {"4.2", "5.8", "5.0"},
      {"0.25", "0.5", "0.375"},
      {"0.6", "1.2", "0.9"}
    ]

    for {a, b, expected} <- @test_data do
      test "returns #{expected} when the input is #{a} and #{b}" do
        # Act
        result = Test.generate_index(unquote(a), unquote(b))

        # Assert
        assert result == unquote(expected)
      end
    end
  end
end
