#!/bin/sh
set -e

# Run the compiled release migration task
/app/bin/konew eval "Konew.Release.migrate"

# Hand over execution to the core application loop
exec "$@"
