#
# Step 1 - Build the OTP binary
#
FROM elixir:1.9-alpine AS builder

ARG APP_VERSION=latest
ENV APP_VERSION=${APP_VERSION}
ENV MIX_ENV=prod

WORKDIR /build

RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add make g++ git openssl-dev python yaml-dev

RUN mix local.rebar --force && \
    mix local.hex --force

COPY mix.* ./
COPY lib lib
COPY priv priv
COPY config config
COPY mix.exs .
COPY mix.lock .

RUN mix deps.get --only prod
RUN mix deps.compile --only prod
RUN mix compile --only prod

RUN mkdir -p /opt/build && \
    mix release && \
    cp -R _build/prod/rel/accent/* /opt/build

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

ARG APP_VERSION=latest
ENV APP_VERSION=${APP_VERSION}

RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add bash openssl erlang-crypto yaml-dev

WORKDIR /opt/accent

# Copy the OTP binary and assets deps from the build step
COPY --from=builder /opt/build .
COPY --from=webapp-builder /opt/build .
COPY --from=jipt-builder /opt/build .

RUN mv /opt/accent/webapp-dist /opt/accent/lib/accent-$APP_VERSION/priv/static/webapp && \
    mv /opt/accent/jipt-dist /opt/accent/lib/accent-$APP_VERSION/priv/static/jipt

# Copy the entrypoint script
COPY priv/scripts/docker-entrypoint.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh

# Create a non-root user
RUN adduser -D accent && chown -R accent: /opt/accent

USER accent

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["start"]
