# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :wttj,
  ecto_repos: [Wttj.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :wttj, WttjWeb.Endpoint,
  url: [host: "localhost"],
  static_url: [path: "/"],
  check_origin: false,
  plug_static: [
    at: "/",
    from: :wttj,
    gzip: false,
    only: ~w(assets fonts images favicon.ico robots.txt index.js)
  ],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: WttjWeb.ErrorHTML, json: WttjWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: :wttj_pubsub,
  live_view: [signing_salt: "HckvAo0X"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :wttj, Wttj.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
