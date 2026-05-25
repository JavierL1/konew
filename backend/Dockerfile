# --- STAGE 1: Build the release ---
FROM elixir:1.19-alpine AS builder

RUN apk add --no-cache build-base git nodejs npm

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

ENV MIX_ENV="prod"

COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
RUN mix deps.compile

COPY assets assets
COPY config config
RUN mix assets.deploy

COPY lib lib
RUN mix compile
RUN mix release

# --- STAGE 2: Run the release ---
FROM alpine:3.19

RUN apk add --no-cache libstdc++ openssl ncurses-libs tini

WORKDIR /app
RUN chown nobody /app
USER nobody

ENV MIX_ENV="prod"

COPY --from=builder --chown=nobody:root /app/_build/prod/rel/konew ./

EXPOSE 4000
EXPOSE 4001

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/app/bin/konew", "start"]
