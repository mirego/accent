#!/bin/sh
set -e

# Run the migration first using the custom release task
/opt/accent/bin/accent eval "Accent.ReleaseTasks.migrate"
/opt/accent/bin/accent eval "Accent.ReleaseTasks.seed"

# Launch the OTP release and replace the caller as Process #1 in the container
exec /opt/accent/bin/accent "$@"
