#
# Step 1 - Build the OTP binary
#
FROM elixir:1.8.1-alpine AS builder

ARG APP_NAME
ARG APP_VERSION
ARG MIX_ENV=prod

ENV APP_NAME=${APP_NAME} \
    APP_VERSION=${APP_VERSION} \
    MIX_ENV=${MIX_ENV}

WORKDIR /build

# This step installs all the build tools we'll need
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache make g++ git openssl-dev nodejs-npm python yaml-dev

RUN mix local.rebar --force && \
    mix local.hex --force

# This copies our app source code into the build container
COPY mix.* ./
RUN mix deps.get --only ${MIX_ENV}
RUN mix deps.compile

COPY . .
RUN mix compile
RUN mix phx.digest

RUN mkdir -p /opt/build && \
    mix release --verbose && \
    cp _build/${MIX_ENV}/rel/${APP_NAME}/releases/${APP_VERSION}/${APP_NAME}.tar.gz /opt/build

RUN cd /opt/build && \
    tar -xzf ${APP_NAME}.tar.gz && \
    rm ${APP_NAME}.tar.gz

COPY webapp /opt/build/webapp

RUN cd /opt/build && npm ci --prefix webapp --no-audit --no-color
RUN cd /opt/build && npm run build-production --prefix webapp

COPY jipt /opt/build/jipt

RUN cd /opt/build && npm ci --prefix jipt --no-audit --no-color
RUN cd /opt/build && npm run build-production --prefix jipt

RUN mv /opt/build/webapp/webapp-dist /opt/build
RUN rm -rf /opt/build/webapp
RUN mv /opt/build/jipt/jipt-dist /opt/build
RUN rm -rf /opt/build/jipt
#
# Step 2 - Build a lean runtime container
#
FROM alpine:3.9

ARG APP_NAME
ARG APP_VERSION
ENV APP_NAME=${APP_NAME} \
    APP_VERSION=${APP_VERSION}

# Update kernel and install runtime dependencies
RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add bash openssl erlang-crypto yaml-dev

WORKDIR /opt/$APP_NAME

# Copy the OTP binary from the build step
COPY --from=builder /opt/build .

RUN cp -r /opt/$APP_NAME/webapp-dist /opt/$APP_NAME/lib/$APP_NAME-$APP_VERSION/priv/static/webapp
RUN cp -r /opt/$APP_NAME/jipt-dist /opt/$APP_NAME/lib/$APP_NAME-$APP_VERSION/priv/static/jipt

# Copy the entrypoint script
COPY priv/scripts/docker-entrypoint.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh

# Create a non-root user
RUN adduser -D $APP_NAME && chown -R accent: /opt/$APP_NAME

USER $APP_NAME

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["foreground"]
