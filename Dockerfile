################################################################################
# Stage 1: Build webapp assets
################################################################################
FROM node:22.21.1-bullseye-slim AS webapp-builder

WORKDIR /opt/build

# Install only required dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy package files first to leverage Docker cache
COPY webapp/package*.json ./

# Install dependencies
RUN npm ci --no-audit --no-color

# Copy source and build
COPY webapp .
RUN npm run build-production


################################################################################
# Stage 2: Build jipt assets in parallel
################################################################################
FROM node:21.6.1-bullseye-slim AS jipt-builder

WORKDIR /opt/build

# Install only required dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy package files first to leverage Docker cache
COPY jipt/package*.json ./

# Install dependencies
RUN npm ci --no-audit --no-color

# Copy source and build
COPY jipt .
RUN npm run build-production


################################################################################
# Stage 3: Build language tool jar in parallel
################################################################################
FROM debian:bullseye-slim AS languagetool-builder

WORKDIR /build

# Install only Java runtime
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        default-jre && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy language tool source and build
COPY vendor/language_tool/priv/ vendor/language_tool/priv/
RUN cd ./vendor/language_tool/priv/native/languagetool && ./gradlew shadowJar

# Prepare output directory for next stage
RUN mkdir -p /build/priv/native/ && \
    cp ./vendor/language_tool/priv/native/languagetool/app/build/libs/language-tool.jar /build/priv/native/


################################################################################
# Stage 4: Build the OTP binary (Elixir app)
################################################################################
FROM hexpm/elixir:1.18.3-erlang-27.3.1-debian-bullseye-20250317-slim AS builder

ENV ERL_AFLAGS="+JMsingle true"
ENV MIX_ENV=prod
WORKDIR /build

# Install only needed build dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        libyaml-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Setup Elixir environment
RUN mix local.rebar --force && \
    mix local.hex --force

# Copy dependency definitions first to leverage caching
COPY mix.* ./
COPY config config

# Get and compile dependencies
RUN mix deps.get --only prod && \
    mix deps.compile --only prod

# Copy application source code
COPY vendor vendor
COPY lib lib
COPY priv priv

# Copy language tool from previous stage
COPY --from=languagetool-builder /build/priv/native/language-tool.jar priv/native/

# Compile the application
RUN mix compile --only prod

# Copy static assets from previous build stages
COPY --from=webapp-builder /opt/build/webapp-dist ./priv/static/webapp
COPY --from=jipt-builder /opt/build/jipt-dist ./priv/static/jipt

# Create the release
RUN mix release && \
    mkdir -p /opt/build && \
    cp -R _build/prod/rel/accent/* /opt/build


################################################################################
# Final Stage: Create lean runtime container
################################################################################
FROM debian:bullseye-slim

# GitHub Container Registry labels
LABEL org.opencontainers.image.source=https://github.com/mirego/accent
LABEL org.opencontainers.image.description="Accent is a developer-oriented tool for translation management"
LABEL org.opencontainers.image.licenses=BSD-3-Clause

# Install only runtime dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        default-jre-headless \
        libyaml-0-2 \
        openssl \
        ca-certificates \
        libncurses5 \
        locales \
        fontconfig \
        hunspell \
        hunspell-fr \
        hunspell-en-ca \
        hunspell-en-us \
        hunspell-es && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

# Set environment variables
ENV MIX_ENV="prod" \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Prepare application directory
WORKDIR /opt/accent

# Create a non-root user for security
RUN chown nobody /opt/accent

# Copy the release from builder stage
COPY --from=builder --chown=nobody:root /opt/build .

# Copy and prepare entrypoint script
COPY priv/scripts/docker-entrypoint.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh

# Switch to non-root user
USER nobody

# Set the entrypoint and default command
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["start"]
