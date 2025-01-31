FROM elixir:1.18.1-otp-27-alpine AS builder

WORKDIR /app
COPY . .

ENV MIX_ENV=prod

RUN apk add --no-cache git libstdc++ ncurses-libs

RUN mix deps.get --only prod && \
    mix compile && \
    mix assets.deploy && \
    mix phx.gen.release && \
    mix release

CMD ["./_build/prod/rel/discord_bot/bin/discord_bot", "start"]
