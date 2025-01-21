defmodule Wttj.Validation.DisplayOrder do
  @moduledoc """
  Validation functions related to the `displayOrder` data type
  """

  @doc """
  Validates that a value matches the correct format.

  DisplayOrder must be formatted as a float, but as a string. For example '1', '2.5', '10.99'. The value '0' is not allowed.

  ## Examples

      iex> Wttj.Validation.DisplayOrder.validate_display_order_type("1")
      {:ok}

      iex> Wttj.Validation.DisplayOrder.validate_display_order_type("0.1")
      {:ok}

      iex> Wttj.Validation.DisplayOrder.validate_display_order_type("1add")
      {:error, "Invalid format for type DisplayOrder. Expected a float, but as a string. For example '1', '2.5', '10.99'. The value '0' is not allowed."}

      iex> Wttj.Validation.DisplayOrder.validate_display_order_type("0")
      {:error, "Invalid format for type DisplayOrder. Expected a float, but as a string. For example '1', '2.5', '10.99'. The value '0' is not allowed."}

  """
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
