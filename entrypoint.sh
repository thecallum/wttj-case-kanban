#!/bin/sh

# Wait for database if needed
# while ! pg_isready -q -h $DATABASE_HOST -p $DATABASE_PORT -U $DATABASE_USER
# do
#   echo "$(date) - waiting for database..."
#   sleep 2
# done

# Create database if it doesn't exist
# if [[ -r /app/bin/your_app_name ]]; then
#   echo "Creating database if it doesn't exist..."
#   /app/bin/your_app_name eval "Wttj.Release.create"
# fi

# Run migrations
if [[ -r /app/bin/your_app_name ]]; then
  echo "Running migrations..."
  /app/bin/your_app_name eval "Wttj.Release.migrate"
fi

exec /app/bin/your_app_name start