#
# Step 1 - Build the OTP binary
#
FROM elixir:1.9-alpine AS builder

ARG APP_NAME
ARG APP_VERSION
ARG MIX_ENV=prod

ENV APP_NAME=${APP_NAME} \
    APP_VERSION=${APP_VERSION} \
    MIX_ENV=${MIX_ENV}

WORKDIR /build

RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add make g++ git openssl-dev python yaml-dev

RUN mix local.rebar --force && \
    mix local.hex --force

COPY mix.* ./
RUN mix deps.get --only ${MIX_ENV}
RUN mix deps.compile

COPY . .
RUN mix compile

RUN mkdir -p /opt/build && \
    mix release && \
    cp -R _build/${MIX_ENV}/rel/${APP_NAME}/* /opt/build

#
# Step 2 - Build webapp and jipt deps
#
FROM alpine:3.9 AS webapp-builder
RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add make git nodejs-npm
WORKDIR /opt/build
COPY webapp .
RUN npm ci --no-audit --no-color && \
    npm run build-production

FROM alpine:3.9 AS jipt-builder
RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add make git nodejs-npm
WORKDIR /opt/build
COPY jipt .
RUN npm ci --no-audit --no-color && \
    npm run build-production
#
# Step 3 - Build a lean runtime container
#
FROM alpine:3.9

ARG APP_NAME
ARG APP_VERSION
ENV APP_NAME=${APP_NAME} \
    APP_VERSION=${APP_VERSION}

RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add bash openssl erlang-crypto yaml-dev

WORKDIR /opt/$APP_NAME

# Copy the OTP binary and assets deps from the build step
COPY --from=builder /opt/build .
COPY --from=webapp-builder /opt/build .
COPY --from=jipt-builder /opt/build .

RUN mv /opt/$APP_NAME/webapp-dist /opt/$APP_NAME/lib/$APP_NAME-$APP_VERSION/priv/static/webapp && \
    mv /opt/$APP_NAME/jipt-dist /opt/$APP_NAME/lib/$APP_NAME-$APP_VERSION/priv/static/jipt

# Copy the entrypoint script
COPY priv/scripts/docker-entrypoint.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh

# Create a non-root user
RUN adduser -D $APP_NAME && chown -R $APP_NAME: /opt/$APP_NAME

USER $APP_NAME

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["start"]
