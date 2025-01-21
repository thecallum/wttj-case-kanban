defmodule Wttj.Validation.DisplayOrderTests do
  use Wttj.DataCase
  alias Wttj.Validation.DisplayOrder
  doctest Wttj.Validation.DisplayOrder

  describe "validate_display_order_type/1" do
    for value <- ["0.1", "1", "1.23", "0.01", "130.56654", 10, 15.33] do
      test "returns ok when value is #{value}" do
        assert DisplayOrder.validate_display_order_type(unquote(value)) == {:ok}
      end
    end

    for value <- ["0", "test", "0.2s", "1,000"] do
      test "returns error when value is #{value}" do
        assert DisplayOrder.validate_display_order_type(unquote(value)) ==
                 {:error,
                  "Invalid format for type DisplayOrder. Expected a float, but as a string. For example '1', '2.5', '10.99'. The value '0' is not allowed."}
      end
    end
  end
end
