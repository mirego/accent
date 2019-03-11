#!/bin/sh
set -e

# Run the migration first using the custom release task
/opt/$APP_NAME/bin/$APP_NAME migrate

# Since an EmberJs app can't be built without its environment, we build it here instead of the Dockerfile.
# This makes the image completly dependent of the deployed instance’s environment.
cd webapp
./node_modules/ember-cli/bin/ember build --prod --output-path=/opt/$APP_NAME/lib/$APP_NAME-$APP_VERSION/priv/static/webapp &
cd ..

cd jipt
PARCEL_WORKERS=1 ./node_modules/parcel-bundler/bin/cli.js build index.ts --experimental-scope-hoisting --out-dir=/opt/$APP_NAME/lib/$APP_NAME-$APP_VERSION/priv/static/jipt &
cd ..

# Launch the OTP release and replace the caller as Process #1 in the container
exec /opt/$APP_NAME/bin/$APP_NAME "$@"
