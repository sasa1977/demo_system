FROM elixir:1.8

# Node setup
RUN apt-get update
RUN apt-get install -y wget inotify-tools
RUN wget https://deb.nodesource.com/setup_8.x
RUN sed -i '/sleep 20/d' ./setup_8.x
RUN bash ./setup_8.x
RUN apt-get install -y nodejs npm
RUN node -v
RUN npm -v

# Elixir setup
RUN mix local.rebar --force
RUN mix local.hex --force

WORKDIR /app
COPY . .

WORKDIR /app/example_system
RUN mix deps.get

WORKDIR /app/example_system/assets
RUN npm install

WORKDIR /app/example_system
RUN mix compile
RUN mix release