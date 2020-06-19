FROM gleamlang/gleam:0.9.0 as gleam-builder
WORKDIR /opt/build
COPY gleam.toml .
COPY rebar.config .
COPY src src
RUN rebar3 compile

#
# Step 1 - Build webapp and jipt deps
#
FROM node:10.16-alpine AS webapp-builder
RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add git
WORKDIR /opt/build
COPY webapp .
RUN npm ci --no-audit --no-color && \
    npm run build-production

FROM node:10.16-alpine AS jipt-builder
RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add git
WORKDIR /opt/build
COPY jipt .
RUN npm ci --no-audit --no-color && \
    npm run build-production

#
# Step 3 - Build the OTP binary
#
FROM hexpm/elixir:1.10.3-erlang-22.3.4.1-alpine-3.11.6 AS builder

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
COPY --from=gleam-builder /opt/build ./gen

RUN mix deps.get --only prod
RUN mix deps.compile --only prod
RUN mix compile --only prod

# Move static assets from other stages into the OTP release.
# Those file will be served by the Elixir app.
COPY --from=webapp-builder /opt/build/webapp-dist ./webapp-dist
COPY --from=jipt-builder /opt/build/jipt-dist ./jipt-dist

RUN mv webapp-dist priv/static/webapp && \
    mv jipt-dist priv/static/jipt

RUN mkdir -p /opt/build && \
    mix release && \
    cp -R _build/prod/rel/accent/* /opt/build

#
# Step 4 - Build a lean runtime container
#
FROM alpine:3.11.6

RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add bash openssl erlang-crypto yaml-dev

WORKDIR /opt/accent
COPY --from=builder /opt/build .

# Copy the entrypoint script
COPY priv/scripts/docker-entrypoint.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh

# Create a non-root user
RUN adduser -D accent && chown -R accent: /opt/accent

USER accent

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["start"]
