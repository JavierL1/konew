# Use the latest stable Elixir and Erlang/OTP 27/28
FROM elixir:1.19-alpine

# Install build dependencies + inotify-tools for Phoenix hot-reloading
RUN apk add --no-cache build-base git bash inotify-tools

ARG USERNAME=vscode
RUN adduser -D $USERNAME
USER $USERNAME
WORKDIR /workspaces

# Update Hex/Rebar to the latest versions
RUN mix local.hex --force && \
    mix local.rebar --force

CMD ["iex", "-S", "mix"]
