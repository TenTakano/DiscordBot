# Build Stage
ARG ELIXIR_VERSION
ARG ERLANG_MAJOR_VERSION

FROM elixir:${ELIXIR_VERSION}-otp-${ERLANG_MAJOR_VERSION}-alpine AS builder

WORKDIR /app
COPY . .

ENV MIX_ENV=prod

RUN apk add --no-cache git

RUN mix deps.get --only prod && \
    mix compile && \
    mix assets.deploy && \
    mix phx.gen.release && \
    mix release

# Runtime Stage
FROM alpine:latest
WORKDIR /app

ENV MIX_ENV=prod

RUN apk add --no-cache libstdc++ ncurses-libs

COPY --from=builder /app/_build/prod/rel/discord_bot .
CMD ["./bin/discord_bot", "start"]
