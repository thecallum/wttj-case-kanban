defmodule Wttj.Validation.DisplayOrder do
  def validate_display_order_type(value) do
    type_error =
      "Invalid format for type DisplayOrder. Expected a float, but as a string. For example '1', '2.5', '10.99'. The value '0' is not allowed."

    value = to_string(value)

    if Regex.match?(~r/^(?!0$)(\d*\.?\d+)$/, value) do
      {:ok}
    else
      {:error, type_error}
    end
  end
end
