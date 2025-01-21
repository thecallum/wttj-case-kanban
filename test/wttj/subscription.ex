defmodule WTTJ.Subscription do
  @callback publish(Plug.Conn.t() | atom(), map(), keyword()) :: :ok | {:error, term()}
end
