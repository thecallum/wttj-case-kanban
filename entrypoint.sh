#!/bin/bash

# Run migrations
mix ecto.create
mix ecto.migrate

# Start Phoenix server
exec mix phx.server