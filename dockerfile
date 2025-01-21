FROM elixir:latest AS builder

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g yarn

RUN mkdir /app
COPY . /app
WORKDIR /app

RUN mix deps.get --only prod
RUN MIX_ENV=prod mix compile

RUN cd assets && yarn 

ENV API_URL=http://localhost:4001/api/graphql/
ENV WS_URL=ws://localhost:4001/socket

RUN MIX_ENV=prod mix assets.deploy

ENV PORT=4001
ENV MIX_ENV=prod
ENV PHX_SERVER=true

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
CMD ["/app/entrypoint.sh"]