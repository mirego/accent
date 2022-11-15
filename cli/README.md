Accent CLI
======

[![Version](https://img.shields.io/npm/v/accent-cli.svg)](https://npmjs.org/package/accent-cli)
[![Build Status](https://img.shields.io/travis/v/accent-cli.svg?branch=master)](https://travis-ci.com/mirego/accent-cli)

<!-- toc -->
* [Usage](#usage)
* [Configuration](#configuration)
* [Commands](#commands)
* [GitHub Actions](#github-actions)
* [License](#license)
* [About Mirego](#about-mirego)
<!-- tocstop -->

# Usage
<!-- usage -->
```sh-session
$ npm install -g accent-cli
$ accent COMMAND
running command...
$ accent (-v|--version|version)
accent-cli/0.12.0 darwin-x64 node-v16.15.1
$ accent --help [COMMAND]
USAGE
  $ accent COMMAND
...
```
<!-- usagestop -->

# Configuration

accent-cli reads from a `accent.json` file. The file should contain valid JSON representing the configuration of your project.

## Example

```
{
  "apiUrl": "http://your.accent.instance",
  "apiKey": "2nziVSaa8yUJxLkwoZA",
  "files": [
    {
      "format": "json",
      "source": "localization/fr/*.json",
      "target": "localization/%slug%/%document_path%.json",
      "hooks": {
        "afterSync": "touch sync-done.txt"
      }
    }
  ]
}
```

## Document configuration

Each operation section `sync` and `addTranslations` can contain the following object:

- `language`: The identifier of the document’s language
- `format`: The format of the document
- `source`: The path of the document. This can contain glob pattern (See [the node glob library] used as a dependancy (https://github.com/isaacs/node-glob))
- `target`: Path of the target languages
- `hooks`: List of hooks to be run

## Hooks

Here is a list of available hooks. Those are self-explanatory

- `beforeSync`
- `afterSync`
- `beforeExport`
- `afterExport`

# Commands
<!-- commands -->
* [`accent export`](#accent-export)
* [`accent format`](#accent-format)
* [`accent help [COMMAND]`](#accent-help-command)
* [`accent jipt PSEUDOLANGUAGENAME`](#accent-jipt-pseudolanguagename)
* [`accent lint`](#accent-lint)
* [`accent stats`](#accent-stats)
* [`accent sync`](#accent-sync)

## `accent export`

Export files from Accent and write them to your local filesystem

```
USAGE
  $ accent export

OPTIONS
  --order-by=index|key  [default: index] Will be used in the export call as the order of the keys

EXAMPLE
  $ accent export
```

_See code: [src/commands/export.ts](https://github.com/mirego/accent/blob/v0.12.0/src/commands/export.ts)_

## `accent format`

Format local files from server. Exit code is 1 if there are errors.

```
USAGE
  $ accent format

OPTIONS
  --order-by=index|key  [default: index] Order of the keys

EXAMPLE
  $ accent format
```

_See code: [src/commands/format.ts](https://github.com/mirego/accent/blob/v0.12.0/src/commands/format.ts)_

## `accent help [COMMAND]`

display help for accent

```
USAGE
  $ accent help [COMMAND]

ARGUMENTS
  COMMAND  command to show help for

OPTIONS
  --all  see all commands in CLI
```

_See code: [@oclif/plugin-help](https://github.com/oclif/plugin-help/blob/v2.1.4/src/commands/help.ts)_

## `accent jipt PSEUDOLANGUAGENAME`

Export jipt files from Accent and write them to your local filesystem

```
USAGE
  $ accent jipt PSEUDOLANGUAGENAME

ARGUMENTS
  PSEUDOLANGUAGENAME  The pseudo language for in-place-translation-editing

EXAMPLE
  $ accent jipt
```

_See code: [src/commands/jipt.ts](https://github.com/mirego/accent/blob/v0.12.0/src/commands/jipt.ts)_

## `accent lint`

Lint local files and display errors if any. Exit code is 1 if there are errors.

```
USAGE
  $ accent lint

EXAMPLE
  $ accent lint
```

_See code: [src/commands/lint.ts](https://github.com/mirego/accent/blob/v0.12.0/src/commands/lint.ts)_

## `accent stats`

Fetch stats from the API and display it beautifully

```
USAGE
  $ accent stats

EXAMPLE
  $ accent stats
```

_See code: [src/commands/stats.ts](https://github.com/mirego/accent/blob/v0.12.0/src/commands/stats.ts)_

## `accent sync`

Sync files in Accent and write them to your local filesystem

```
USAGE
  $ accent sync

OPTIONS
  --add-translations                Add translations in Accent to help translators if you already have translated
                                    strings

  --dry-run                         Do not write the file from the export _after_ the operation

  --merge-type=smart|passive|force  [default: smart] Will be used in the add translations call as the "merge_type" param

  --order-by=index|key              [default: index] Will be used in the export call as the order of the keys

  --sync-type=smart|passive         [default: smart] Will be used in the sync call as the "sync_type" param

EXAMPLE
  $ accent sync
```

_See code: [src/commands/sync.ts](https://github.com/mirego/accent/blob/v0.12.0/src/commands/sync.ts)_
<!-- commandsstop -->

# GitHub Actions

In addition to syncing the translations manually, you can add a GitHub Actions workflow to your project in order to automate the process.

## Example

```
name: Accent

on:
  schedule:
    - cron: "0 4 * * *"

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 16
      - run: npm install -g accent-cli
      - run: accent sync --add-translations --merge-type=passive --order-by=key
      - uses: peter-evans/create-pull-request@v4
        with:
          add-paths: |
            *.json
          commit-message: Update translations
          committer: github-actions[bot]@users.noreply.github.com
          author: github-actions[bot]@users.noreply.github.com
          base: master
          branch: accent
          delete-branch: true
          title: New translations are available to merge
          body: |
            The translation files have been updated, feel free to merge this pull request
          draft: false
```

In this example the translations will be synchronized daily at midnight eastern time. Using a pull request gives you the opportunity to review the changes before merging them in your codebase.

# License

`accent-cli` is © 2019 [Mirego](http://www.mirego.com) and may be freely distributed under the [New BSD license](http://opensource.org/licenses/BSD-3-Clause).  See the [`LICENSE.md`](https://github.com/mirego/accent-cli/blob/master/LICENSE.md) file.

# About Mirego

[Mirego](http://mirego.com) is a team of passionate people who believe that work is a place where you can innovate and have fun. We’re a team of [talented people](http://life.mirego.com) who imagine and build beautiful Web and mobile applications. We come together to share ideas and [change the world](http://mirego.org).

We also [love open-source software](http://open.mirego.com) and we try to give back to the community as much as we can.
