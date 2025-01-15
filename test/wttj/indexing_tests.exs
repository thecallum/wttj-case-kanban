defmodule Wttj.IndexingTest do
  use ExUnit.Case
  alias Wttj.Indexing

  @moduledoc """
  Tests generate_index/2 method, which generates the next index for a candidate. This covers the following scenarios:
  - No existing indices (new list)
  - Index generation between existing items
  - Index generation at the start of a list
  - Index generation at the end of a list
  """

  describe "generate_index/2 when initializing first index" do
    test "returns '1' as this is the first item" do
      assert Indexing.generate_index(nil, nil) == "1"
    end
  end

  describe "generate_index/2 when inserting at start" do
    @test_data [
      {"5.15", "4"},
      {"3.545", "2"},
      {"300.545", "299"},
      {"1", "0.5"},
      {"0.1", "0.05"}
    ]

    for {input, expected} <- @test_data do
      test "returns #{expected} when input is #{input}" do
        assert Indexing.generate_index(nil, unquote(input)) == unquote(expected)
      end
    end
  end

  describe "generate_index/2 when inserting at end" do
    @test_data [
      {"5.15", "6"},
      {"3.545", "4"},
      {"300.545", "301"},
      {"1", "2"},
      {"0.1", "1"}
    ]

    for {input, expected} <- @test_data do
      test "returns #{expected} when input is #{input}" do
        assert Indexing.generate_index(unquote(input), nil) == unquote(expected)
      end
    end
  end

  describe "generate_index/2 when inserting between items" do
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
      test "returns #{expected} when inputs are #{a} and #{b}" do
        assert Indexing.generate_index(unquote(a), unquote(b)) == unquote(expected)
      end
    end
  end
end
