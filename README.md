# Wttj

## Requirements

- Elixir 1.17.2-otp-27
- Erlang 27.0.1
- Postgresql
- Nodejs 20.11.0
- Yarn

## Getting started

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
- install assets and start front

```bash
cd assets
yarn
yarn dev
```

### Running the app via Docker

It may take a few minutes to build. 

```bash
docker-compose build phoenix
docker-compose up phoenix
```

The app should be running on [http://localhost:4001/](http://localhost:4001/).


### Known issues

- Currently, the `display_order` property is still stored as a string within the database. If the value of `display_order` for any candidate exceeds 10, it breaks the ordering validation. This will be most noticable if you try drag a candidate to the end of a list, after 10. You will see the error message "more than one candidate found within range".


### tests

- backend: `mix test`
- front: `cd assets & yarn test`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix
