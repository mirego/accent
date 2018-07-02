<p align="center">
  <img src="logo.svg" alt="Accent Logo" width="500" />
</p>

[Website](https://www.accent.reviews) • [GraphiQL](https://www.accent.reviews/documentation)

[![Build Status](https://travis-ci.org/mirego/accent.svg?branch=master)](https://travis-ci.org/mirego/accent)
[![Coverage Status](https://coveralls.io/repos/github/mirego/accent/badge.svg?branch=master)](https://coveralls.io/github/mirego/accent?branch=master)

**The first developer-oriented translation tool**. Accent’s engine coupled with the asynchronous flow between the translator and the developer is what makes Accent the most awesome tool of all.

The Accent API provides a powerful abstraction around the process of translating and maintaining the translations of an app.

* **Collaboration**. Centralize your discussions around translations.
* **History**. Full history control and actions rollback. _Who_ did _what_, _when_.
* **UI**. Simple yet powerful UI to enable translator and developer to be productive.
* **GraphQL**. The API that powers the UI is open and documented. It’s easy to build a plugin/cli/library around Accent.

## Contents

* [Requirements](#requirements)
* [Mix commands](#executing-mix-commands)
* [Quickstart](#quickstart)
* [Environment variables](#environment-variables)
* [Tests](#tests)
* [Heroku](#deploy-on-heroku)
* [Contribute](#contribute)

## Requirements

- `erlang ~> 20.1`
- `elixir ~> 1.6.0`
- `postgres >= 9.4`
- `node.js >= 8.5.0`
- `libyaml >= 0.1.7`

## Executing mix commands

The app is modeled with the [_Twelve-Factor App_](https://12factor.net/) architecture, all configurations are stored in the environment.

When executing `mix` commands, you should always make sure that the required environment variables are present. You can `source`, use [nv](https://github.com/jcouture/nv) or a custom l33t bash script.

Every following steps assume you have this kind of system.

But Accent can be run with default environment variables if you have a PostgreSQL user named `postgres` listening on port `5432` on `localhost`.

### Example

With `nv` you inject the environment keys in the context with:

```
$ nv .env mix <mix command>
```

## Quickstart

1. If you don’t already have it, install `nodejs` with `brew install nodejs`
1. If you don’t already have it, install `elixir` with `brew install elixir`
2. If you don’t already have it, install `libyaml` with `brew install libyaml`
2. If you don’t already have it, install `postgres` with `brew install postgres` or the [macOS app](https://postgresapp.com/)
3. Install dependencies with `mix deps.get` and `npm --prefix webapp install`
4. Create and migrate your database with `mix ecto.setup`
5. Start Phoenix endpoint with `mix phx.server`
5. Start Ember server with `npm --prefix webapp run start`
6. That’s it!

## Environment variables

Accent provides a default value for every required environment variable. This means that with the right PostgreSQL setup, you can just run `mix phx.server`.

| Variable            | Default                                   | Description                                                                                                                                                |
|---------------------|-------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `MIX_ENV`           | `dev`                                     | The application environment (`dev`, `prod`, or `test`)                                                                                                     |
| `DATABASE_URL`      | `postgres://localhost/accent_development` | A valid database URL                                                                                                                                       |
| `CANONICAL_HOST`    | `localhost`                               | The host that will be used to build internal URLs                                                                                                          |
| `PORT`              | `4000`                                    | A port to run the API on                                                                                                                                   |
| `WEBAPP_PORT`       | `4200`                                    | A port to run the Webapp on (only used in `dev` environment)                                                                                               |
| `API_HOST`          | `http://localhost:4000`                   | The API host                                                                                                                                               |
| `API_WS_HOST`       | `ws://localhost:4000`                     | The API Websocket host                                                                                                                                     |
| `WEBAPP_EMAIL_HOST` | _none_                                    | The Web client’s hostname. Used in the sent emails to link to the right URL. There is no default value, please provide a value if you want to send emails. |
| `MAILER_FROM`       | _none_                                    | The email address used to send emails. There is no default value, please provide a value if you want to send emails.                                       |

### Production setup

| Variable               | Default | Description |
|------------------------|---------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `SENTRY_DSN`           | _none_  | The *secret* Sentry DSN used to collect API runtime errors                                                                                                                                  |
| `WEBAPP_SENTRY_DSN`    | _none_  | The *public* Sentry DSN used to collect Webapp runtime errors                                                                                                                               |
| `GOOGLE_API_CLIENT_ID` | _none_  | When deploying in a `prod` environment, the Google login is the only way to authenticate user. In `dev` environment, a fake login provider is used so you don’t have to setup a Google app. |
| `RESTRICTED_DOMAIN`    | _none_  | If specified, only authenticated users from this domain name will be able to create new projects. |

## Tests

### API

Accent provides a default value for every required environment variable. This means that with the right PostgreSQL setup (and a few setup commands), you can just run `mix test`.

```
$ npm --prefix webapp run build
$ mix run ./priv/repo/seeds.exs
$ mix test
```

## Deploy on Heroku

An Heroku-compatible `app.json` makes it easy to deploy the application on Heroku.

<a href="https://heroku.com/deploy">
  <img src="https://www.herokucdn.com/deploy/button.svg" alt="Deploy on Heroku" />
</a>

## Contribute

Before opening a pull request, please open an issue first.

Once you’ve made your additions and the test suite passes, go ahead and open a PR!

Don’t forget to run the `./priv/scripts/ci-check.sh` script to make sure that the CI build will pass :)

## Contributors

* [@simonprev](https://github.com/simonprev)
* [@loboulet](https://github.com/loboulet)
* [@remiprev](https://github.com/remiprev)
* [@charlesdemers](https://github.com/charlesdemers)
* [@ddrmanxbxfr](https://github.com/ddrmanxbxfr)
* [@thermech](https://github.com/thermech)

## License

Accent is © 2015-2018 [Mirego](https://www.mirego.com) and may be freely distributed under the [New BSD license](http://opensource.org/licenses/BSD-3-Clause). See the [`LICENSE.md`](https://github.com/mirego/accent/blob/master/LICENSE.md) file.

## About Mirego

[Mirego](https://www.mirego.com) is a team of passionate people who believe that work is a place where you can innovate and have fun. We’re a team of [talented people](https://life.mirego.com) who imagine and build beautiful Web and mobile applications. We come together to share ideas and [change the world](http://www.mirego.org).

We also [love open-source software](https://open.mirego.com) and we try to give back to the community as much as we can.
