#
# Build webapp and jipt deps
#
FROM node:16.19-bullseye-slim AS webapp-builder
RUN apt-get update -y && \
    apt-get install -y build-essential git python3 python3-pip && \
    apt-get clean && \
    rm -f /var/lib/apt/lists/*_*
WORKDIR /opt/build
COPY webapp .
RUN npm ci --no-audit --no-color && \
    npm run build-production

FROM node:16.19-bullseye-slim AS jipt-builder
RUN apt-get update -y && \
    apt-get install -y build-essential git python3 python3-pip && \
    apt-get clean && \
    rm -f /var/lib/apt/lists/*_*
WORKDIR /opt/build
COPY jipt .
RUN npm ci --no-audit --no-color && \
    npm run build-production

#
# Build the OTP binary
#
FROM hexpm/elixir:1.14.3-erlang-25.1.2-debian-bullseye-20221004-slim AS builder

ENV MIX_ENV=prod

WORKDIR /build

# Install Debian dependencies
RUN apt-get update -y && \
    apt-get install -y build-essential git libyaml-dev && \
    apt-get clean && \
    rm -f /var/lib/apt/lists/*_*

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
# Build a lean runtime container
#
FROM alpine:3.17.0

FROM debian:bullseye-20230109

RUN apt-get update -y && \
    apt-get install -y bash libyaml-dev openssl libncurses5 locales fontconfig hunspell hunspell-fr hunspell-en-ca hunspell-en-us hunspell-es && \
    apt-get clean && \
    rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV MIX_ENV="prod"
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /opt/accent

# Create a non-root user
RUN chown nobody /opt/accent

COPY --from=builder --chown=nobody:root /opt/build .

# Copy the entrypoint script
COPY priv/scripts/docker-entrypoint.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh

USER nobody

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["start"]

