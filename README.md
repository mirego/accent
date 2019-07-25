<div align="center">
  <img src="logo.svg" width="300" />
  <p>
    <br /><strong>The first developer-oriented translation tool</strong>
    <br />True asynchronous flow between translators and your team.
    <br />
  </p>
</div>

[Website](https://www.accent.reviews) • [GraphiQL](https://www.accent.reviews/documentation)

[![Build Status](https://travis-ci.com/mirego/accent.svg?branch=master)](https://travis-ci.com/mirego/accent)
[![Coverage Status](https://coveralls.io/repos/github/mirego/accent/badge.svg?branch=master)](https://coveralls.io/github/mirego/accent?branch=master) [![Join the chat at https://gitter.im/mirego/accent](https://badges.gitter.im/mirego/accent.svg)](https://gitter.im/mirego/accent?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Accent provides a powerful abstraction around the process maintaining translations in a web/native app.

- **History**. Full history control and actions rollback. _Who_ did _what_, _when_.
- **UI**. Simple yet powerful UI to enable translator and developer to be productive.
- **CLI**. [Command line tool](https://github.com/mirego/accent-cli) to easily add Accent to your developer flow.
- **Collaboration**. Centralize your discussions around translations.
- **GraphQL**. The API that powers the UI is open and documented. It’s easy to build a plugin/cli/library around Accent.

## Contents

| Section                                             | Description                                                          |
| --------------------------------------------------- | -------------------------------------------------------------------- |
| [🚧 Requirements](#-requirements)                   | Dependencies required to run Accent’ stack                           |
| [🎛 Mix commands](#-executing-mix-commands)          | How to execute mix task with the Twelve-Factor pattern               |
| [🏎 Quickstart](#-quickstart)                        | Steps to run the project, from API to webapp, with or without Docker |
| [🌳 Environment variables](#-environment-variables) | Required and optional env var used                                   |
| [✅ Tests](#-tests)                                 | How to run the extensive tests suite                                 |
| [🚀 Heroku](#-heroku)                               | Easy deployment setup with Heroku                                    |
| [🌎 Contribute](#-contribute)                       | How to contribute to this repo                                       |

## 🚧 Requirements

- `erlang ~> 21.2`
- `elixir ~> 1.8`
- `postgres >= 9.4`
- `node.js >= 8.5.0`
- `libyaml >= 0.1.7`

## 🎛 Executing mix commands

The app is modeled with the [_Twelve-Factor App_](https://12factor.net/) architecture, all configurations are stored in the environment.

When executing `mix` commands, you should always make sure that the required environment variables are present. You can `source`, use [nv](https://github.com/jcouture/nv) or a custom l33t bash script.

Every following steps assume you have this kind of system.

But Accent can be run with default environment variables if you have a PostgreSQL user named `postgres` listening on port `5432` on `localhost`.

### Example

With `nv` you inject the environment keys in the context with:

```shell
$ nv .env mix <mix command>
```

## 🏎 Quickstart

_This is the full development setup. To simply run the app, see the *Docker* instructions_

1. If you don’t already have it, install `nodejs` with `brew install nodejs`
2. If you don’t already have it, install `elixir` with `brew install elixir`
3. If you don’t already have it, install `libyaml` with `brew install libyaml`
4. If you don’t already have it, install `postgres` with `brew install postgres` or the Docker setup as described below.
5. Install dependencies with `make dependencies`
6. Create and migrate your database with `mix ecto.setup`
7. Start Phoenix endpoint with `mix phx.server`
8. Start Ember server with `npm run start --prefix webapp`

_That’s it!_

### Makefile

The Makefile should be the main entry for common tasks such as tests, linting, Docker, etc. This simplify the developpement process since you don’t have to search for which service provides which command. `mix`, `npm`, `prettier`, `docker`, `stylelint`, etc are all used in the Makefile.

### Docker

For the production setup, we use Docker to build an OTP release of the app. With docker-compose, you can run the image locally. Here are the steps to have a working app running locally with Docker:

_When running the production env, you need to provide a valid GOOGLE_API_CLIENT_ID in the `docker-compose.yml` file._

1. Run `make build` to build the OTP release with Docker
2. Run `make dev-start-postgresql` to start an instance of Postgresql. The instance will run on port 5432 with the `postgres` user. You can change those values in the `docker-compose.yml` file.
3. Run `make dev-start-application` to start the app! The release hook of the release will execute migrations and seeds before starting the webserver on port 4000 (again you can change the settings in `docker-compose.yml`)

_That’s it! You now have a working Accent instance without installing Elixir or Node!_

## 🌳 Environment variables

Accent provides a default value for every required environment variable. This means that with the right PostgreSQL setup, you can just run `mix phx.server`.

| Variable         | Default                                   | Description                                                                           |
| ---------------- | ----------------------------------------- | ------------------------------------------------------------------------------------- |
| `API_HOST`       | `http://localhost:4000`                   | The API host                                                                          |
| `API_WS_HOST`    | `ws://localhost:4000`                     | The API Websocket host                                                                |
| `CANONICAL_HOST` | `localhost`                               | The host that will be used to build internal URLs                                     |
| `DATABASE_URL`   | `postgres://localhost/accent_development` | A valid database URL                                                                  |
| `MIX_ENV`        | `dev`                                     | The application environment (`dev`, `prod`, or `test`)                                |
| `PORT`           | `4000`                                    | A port to run the API on                                                              |
| `WEBAPP_PORT`    | `4200`                                    | A port to run the Webapp on (only used in `dev` environment)                          |
| `WEBAPP_URL`     | `http://localhost:4000`                   | The Web client’s endpoint. Used in the authentication process and in the sent emails. |

### Production setup

| Variable                | Default | Description                                                                                       |
| ----------------------- | ------- | ------------------------------------------------------------------------------------------------- |
| `ERLANG_COOKIE`         | _none_  | The _erlang_ cookie required for starting the release                                             |
| `RESTRICTED_DOMAIN`     | _none_  | If specified, only authenticated users from this domain name will be able to create new projects. |
| `SENTRY_DSN`            | _none_  | The _secret_ Sentry DSN used to collect API runtime errors                                        |
| `WEBAPP_SENTRY_DSN`     | _none_  | The _public_ Sentry DSN used to collect Webapp runtime errors                                     |

### Authentication setup

Various login providers are included in Accent using Uberauth to abstract services.

| Variable                   | Default | Description                                                                                                                               |
| -------------------------- | ------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `DUMMY_LOGIN_ENABLED`      | _none_  | If specified (or no other authentication configs are provided), the password-less authentication (with only the email) will be available. |
| `GITHUB_CLIENT_ID`         | _none_  |                                                                                                                                           |
| `GITHUB_CLIENT_SECRET`     | _none_  |                                                                                                                                           |
| `GOOGLE_API_CLIENT_ID`     | _none_  |                                                                                                                                           |
| `GOOGLE_API_CLIENT_SECRET` | _none_  |                                                                                                                                           |
| `SLACK_CLIENT_ID`          | _none_  |                                                                                                                                           |
| `SLACK_CLIENT_SECRET`      | _none_  |                                                                                                                                           |
| `SLACK_TEAM_ID`            | _none_  |                                                                                                                                           |

### Email setup

If you want to send emails, you’ll have to configure the following environment variables:

| Variable          | Default | Description                                                  |
| ----------------- | ------- | ------------------------------------------------------------ |
| `MAILER_FROM`     | _none_  | The email address used to send emails.                       |
| `SMTP_ADDRESS`    | _none_  | The SMTP server address you want to use to send your emails. |
| `SMTP_API_HEADER` | _none_  | An optional API header that will be added to sent emails.    |
| `SMTP_PORT`       | _none_  | The port ex: (25, 465, 587).                                 |
| `SMTP_PASSWORD`   | _none_  | The password for authentification.                           |
| `SMTP_USERNAME`   | _none_  | The username for authentification.                           |

## ✅ Tests

### API

Accent provides a default value for every required environment variable. This means that with the right PostgreSQL setup (and a few setup commands), you can just run `mix test`.

```shell
$ npm --prefix webapp run build
$ mix run ./priv/repo/seeds.exs
$ mix test
```

The full check that runs in the CI environment can be executed with `./priv/scripts/ci-check.sh`.

## 🚀 Deploy on Heroku

An Heroku-compatible `app.json` makes it easy to deploy the application on Heroku.

<a href="https://heroku.com/deploy">
  <img src="https://www.herokucdn.com/deploy/button.svg" alt="Deploy on Heroku" />
</a>

## 🌎 Contribute

Before opening a pull request, please open an issue first.

Once you’ve made your additions and the test suite passes, go ahead and open a PR!

Don’t forget to run the `./priv/scripts/ci-check.sh` script to make sure that the CI build will pass :)

## License

Accent is © 2015-2019 [Mirego](https://www.mirego.com) and may be freely distributed under the [New BSD license](http://opensource.org/licenses/BSD-3-Clause). See the [`LICENSE.md`](https://github.com/mirego/accent/blob/master/LICENSE.md) file.

## About Mirego

[Mirego](https://www.mirego.com) is a team of passionate people who believe that work is a place where you can innovate and have fun. We’re a team of [talented people](https://life.mirego.com) who imagine and build beautiful Web and mobile applications. We come together to share ideas and [change the world](http://www.mirego.org).

We also [love open-source software](https://open.mirego.com) and we try to give back to the community as much as we can.
