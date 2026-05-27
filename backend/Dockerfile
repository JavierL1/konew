# --- STAGE 1: Build the release ---
FROM elixir:1.19-alpine AS builder

RUN apk add --no-cache build-base git nodejs npm

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

ENV MIX_ENV="prod"

# 1. Fetch and compile Elixir dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
RUN mix deps.compile

# 2. Pull down npm dependencies
COPY assets/package.json assets/package-lock.json ./assets/
RUN cd assets && npm ci

# 3. Copy config, migrations (priv), and source files
COPY config config
COPY priv priv
COPY lib lib

# 4. Compile application code FIRST for phoenix_colocated
RUN mix compile

# 5. Copy assets and deploy frontend artifacts
COPY assets assets
RUN mix assets.deploy

# 6. Finalize release compilation
RUN mix release

# --- STAGE 2: Run the release ---
FROM alpine:latest

# Installs shared C-libraries needed for the runtime and the tini init system
RUN apk add --no-cache libstdc++ openssl ncurses-libs tini

WORKDIR /app

# Ensure ownership permissions are set correctly for non-root execution
RUN chown nobody /app

ENV MIX_ENV="prod"

# Copy the compiled binaries into the execution runtime space
COPY --from=builder --chown=nobody:root /app/_build/prod/rel/konew ./

# Copy and grant execution rights to your migration wrapper script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 4000

# Execute entrypoint.sh using tini to reap zombie processes safely
ENTRYPOINT ["/sbin/tini", "--", "/app/entrypoint.sh"]
CMD ["/app/bin/konew", "start"]
