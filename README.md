<h3 align="center">
  <img src="logo.svg" alt="Accent Logo" width=500 />
</h3>

[Website](https://www.accent.reviews) • [GraphiQL](https://www.accent.reviews/documentation)

[![Build Status](https://travis-ci.com/mirego/accent-web-v2.svg?token=ySqXG5pmHqKKGyP2ECxE&branch=master)](https://travis-ci.com/mirego/accent-web-v2)

**The first developer oriented translation tool**. Accent’s engine coupled with the asynchronous flow between the translator and the developer is what makes Accent the most awesome tool of all.

The Accent API provides a powerful abstraction around the process of translating and maintaing the translations of an app.

* **Collaboration**. Centralize your discussions around translations.
* **History**. Full history control and actions rollback. _Who_ did _what_, _when_.
* **UI**. Simple yet powerful UI to enable translator and developer to be productive.
* **GraphQL**. The API that powers the UI is open and documented. It’s easy to build plugin/cli/librairy around Accent.

## Contents

* [Requirements](#requirements)
* [Mix commands](#executing-mix-commands)
* [Quickstart](#quickstart)
* [Environment variables](#environment-variables)
* [Tests](#tests)
* [Heroku](#deploy-on-heroku)
* [Contribute](#contribute)

## Requirements

- Erlang OTP 20.1
- Elixir 1.6.2
- PostgreSQL >= 9.4
- Node.js >= 8.5.0
- libyaml

## Executing mix commands

The app is modeled with the _Twelve-Factor_  architecture, all configurations are stored in the environment.

When executing mix command, you should always make sure that the required system `ENV` are present. You can `source`, use [nv](https://github.com/jcouture/nv) or a custom l33t bash script.

Every following steps assume you have this kind of system.
But Accent can be run with default env var if you have a PostgreSQL user named postgres listening on port 5432 on localhost.

### Example

With `nv` you inject the environment keys in the context with:

```shell
> nv .env mix <mix command>

```

## Quickstart

  1. If you don’t already have it, install `nodejs` with `brew install nodejs`
  1. If you don’t already have it, install `elixir` with `brew install elixir`
  2. If you don’t already have it, install `libyaml` with `brew install libyaml`
  2. If you don’t already have it, install `PostgreSQL` with `brew install postgres` or the [macOS app](https://postgresapp.com/)
  3. Install dependencies with `mix deps.get` and `npm --prefix webapp install`.
  4. Create and migrate your database with `mix ecto.setup`
  5. Start Phoenix endpoint with `mix phx.server`
  5. Start Ember server with `npm --prefix webapp run start`
  6. That’s it.

## Environment variables

This app provides default value for every env var. This means that with the right PostgreSQL setup, you can just run `mix phx.server`.

- `DATABASE_URL=postgres://localhost/accent_development`: A valid database url. Like the one used by Heroku.
- `PORT=4000`: A PORT to run your app.
- `WEBAPP_PORT=4200`: A PORT to run your webapp. (only used in dev)
- `API_HOST=http://localhost:4000`: The host of the API.
- `API_WS_HOST=ws://localhost:4000`: The websocket host of the API.
- `MIX_ENV=dev` : Environment to run mix {dev, prod, test}
- `WEBAPP_EMAIL_HOST=localhost:8001`: Web client’s hostname. Used in the sent emails to link to the right URL. There is no default value, please provide a value if you want to send emails.
- `MAILER_FROM=anEmail@gmail.com`: Email address used in the sent email. There is no default value, please provide a value if you want to send emails.

### Production setup

- `SENTRY_DSN`
- `WEBAPP_SENTRY_DSN`
- `GOOGLE_API_CLIENT_ID`: When deploying in a production env, the Google login is the only way to authenticate user. In dev, a fake login provider is used so you don’t have to setup a Google app.

## Tests

### API

This app provides default value for every env var required in test. This means that with the right PostgreSQL setup, you can just run `mix test`.

- `mix test`

## Deploy on Heroku

To successfully deploy the application on Heroku, you must use these buildpacks:

_The first buildpack is to use the Aptfile to install libyaml._

```shell
$ heroku buildpacks:add --index 1 https://github.com/heroku/heroku-buildpack-apt#usr-local-paths
$ heroku buildpacks:add --index 2 https://github.com/HashNuke/heroku-buildpack-elixir
$ heroku buildpacks:add --index 3 https://github.com/gjaldon/heroku-buildpack-phoenix-static
```

## Contribute

Before opening a pull request, please open an issue first.

```shell
$ git clone https://github.com/mirego/accent-web-v2.git
$ cd accent-web-v2
$ mix deps.get
$ mix test
```

Once you've made your additions and the test suite passes, go ahead and open a PR!
Don’t forget to run the `./priv/scripts/ci-check.sh` script to make sure that the CI will pass :)

## About Mirego

[Mirego](http://mirego.com) is a team of passionate people who believe that work is a place where you can innovate and have fun. We're a team of [talented people](http://life.mirego.com) who imagine and build beautiful Web and mobile applications. We come together to share ideas and [change the world](http://mirego.org).

We also [love open-source software](http://open.mirego.com) and we try to give back to the community as much as we can.
