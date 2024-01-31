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
accent-cli/0.16.0 darwin-arm64 node-v16.19.1
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
  "version": {
    "branchVersionPrefix": "release/"
  }
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

Format for the `accent.json` file.

- `apiUrl`: The base URL of your Accent Instance
- `apiKey`: Api Key to your Accent Instance
- `project`: Your Project uuid

Available ENV variables. (Each variable will override `accent.json` variables if set)

- `ACCENT_API_KEY`: The base URL of your Accent Instance
- `ACCENT_API_URL`: Api Key to your Accent Instance
- `ACCENT_PROJECT`: Your Project uuid

Version object configuration

- `branchVersionPrefix`: The Git branch prefix use to extract the file version

Each operation section `sync` and `addTranslations` can contain the following object:

- `language`: The identifier of the document’s language
- `format`: The format of the document
- `source`: The path of the document. This can contain glob pattern (See [the node glob library] used as a dependancy (https://github.com/isaacs/node-glob))
- `target`: Path of the target languages
- `namePattern`: Pattern to use to save the document name in Accent.
- `hooks`: List of hooks to be run

## Name pattern

`file` (default): Use the name of the file without the extension. In the example, the document name in Accent will be `Localizable`.

```
{
  "files": [
    {
      "namePattern": "file",
      "format": "strings",
      "source": "Project/Resources/en.lproj/Localizable.strings",
      "target": "Project/Resources/%slug%.lproj/%document_path%.strings"
    }
  ]
}
```

`fileWithSlugSuffix`: Use the name of the file without the extension but also stripping the language slug in the file suffix. In the example, the document name in Accent will be `Localizable`.

```
{
  "files": [
    {
      "namePattern": "fileWithSlugSuffix",
      "format": "strings",
      "source": "Project/Resources/Localizable.en.strings",
      "target": "Project/Resources/%document_path%.%slug%.strings"
    }
  ]
}
```

`parentDirectory`: Use the name of the directory instead of the file name. This is useful for framework which name the file with only the language. In the example, the document name in Accent will be `translations`.

```
{
  "files": [
    {
      "namePattern": "parentDirectory",
      "format": "json",
      "source": "translations/en.json",
      "target": "translations/%slug%.json"
    }
  ]
}
```

`fileWithParentDirectory`: Use the path of the file in addition to the file name. This is useful if you want to keep your file in multiple nested directories, per language. Use the position of the `%slug%` placeholder in the `target` as the root of the path.

```
{
  "files": [
      {
          "namePattern": "fileWithParentDirectory",
          "source": "translations/en/**/*.json",
          "target": "translations/%slug%/%document_path%.json",
      }
  ]
}
```

Given this configuration and a file layout like this:

```
my-project/
  accent.json
  translations/
    en/
      foo/
        locales.json
    fr/
      foo/
        locales.json
```

The document name in Accent will be named `foo/locales`.

## Hooks

Here is a list of available hooks. Those are self-explanatory

- `beforeSync`
- `afterSync`
- `beforeExport`
- `afterExport`

## Version

Version can be extracted from the current Git branch name.

```
  "version": {
    "branchVersionPrefix": "release/"
  }
```

Naming a branch `release/v1.0.0` will cause the `sync` and `stats` CLI commands to be invoked as if `--version=1.0.0` had been specified.

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
  --config=config       [default: accent.json] Path to the config file
  --order-by=index|key  [default: index] Order of the keys
  --version=version     Fetch a specific version

EXAMPLES
  $ accent export
  $ accent export --order-by=key --version=build.myapp.com:0.12.345
```

_See code: [src/commands/export.ts](https://github.com/mirego/accent/blob/v0.16.0/src/commands/export.ts)_

## `accent format`

Format local files from server. Exit code is 1 if there are errors.

```
USAGE
  $ accent format

OPTIONS
  --config=config                   [default: accent.json] Path to the config file
  --order-by=index|key|-index|-key  [default: index] Order of the keys

EXAMPLE
  $ accent format
```

_See code: [src/commands/format.ts](https://github.com/mirego/accent/blob/v0.16.0/src/commands/format.ts)_

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

_See code: [@oclif/plugin-help](https://github.com/oclif/plugin-help/blob/v3.2.18/src/commands/help.ts)_

## `accent jipt PSEUDOLANGUAGENAME`

Export jipt files from Accent and write them to your local filesystem

```
USAGE
  $ accent jipt PSEUDOLANGUAGENAME

ARGUMENTS
  PSEUDOLANGUAGENAME  The pseudo language for in-place-translation-editing

OPTIONS
  --config=config  [default: accent.json] Path to the config file

EXAMPLE
  $ accent jipt
```

_See code: [src/commands/jipt.ts](https://github.com/mirego/accent/blob/v0.16.0/src/commands/jipt.ts)_

## `accent lint`

Lint local files and display errors if any. Exit code is 1 if there are errors.

```
USAGE
  $ accent lint

OPTIONS
  --config=config  [default: accent.json] Path to the config file

EXAMPLE
  $ accent lint
```

_See code: [src/commands/lint.ts](https://github.com/mirego/accent/blob/v0.16.0/src/commands/lint.ts)_

## `accent stats`

Fetch stats from the API and display them beautifully

```
USAGE
  $ accent stats

OPTIONS
  --check-reviewed    Exit 1 when reviewed percentage is not 100%
  --check-translated  Exit 1 when translated percentage is not 100%
  --config=config     [default: accent.json] Path to the config file
  --version=version   View stats for a specific version

EXAMPLE
  $ accent stats
```

_See code: [src/commands/stats.ts](https://github.com/mirego/accent/blob/v0.16.0/src/commands/stats.ts)_

## `accent sync`

Sync files in Accent and write them to your local filesystem

```
USAGE
  $ accent sync

OPTIONS
  --add-translations                Add translations in Accent to help translators if you already have translated
                                    strings locally

  --config=config                   [default: accent.json] Path to the config file

  --dry-run                         Do not write the file from the export _after_ the operation

  --merge-type=smart|passive|force  [default: passive] Algorithm to use on existing strings when adding translation

  --order-by=index|key              [default: index] Will be used in the export call as the order of the keys

  --sync-type=smart|passive         [default: smart] Algorithm to use on existing strings when syncing the main language

  --version=version                 Sync a specific version, the tag needs to exists in Accent first

EXAMPLES
  $ accent sync
  $ accent sync --dry-run --sync-type=force
  $ accent sync --add-translations --merge-type=smart --order-key=key --version=v0.23
```

_See code: [src/commands/sync.ts](https://github.com/mirego/accent/blob/v0.16.0/src/commands/sync.ts)_
<!-- commandsstop -->

# GitHub Actions

In addition to syncing the translations manually, you can add a GitHub Actions workflow to your project in order to automate the process.

## Example

```yaml
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
      - uses: mirego/create-pull-request@v5
        with:
          add-paths: "*.json"
          commit-message: Update translations
          committer: github-actions[bot] <github-actions[bot]@users.noreply.github.com>
          author: github-actions[bot] <github-actions[bot]@users.noreply.github.com>
          branch: accent
          draft: false
          delete-branch: true
          title: New translations are available to merge
          body: The translation files have been updated, feel free to merge this pull request after review.
```

In this example the translations will be synchronized daily at midnight eastern time. Using a pull request gives you the opportunity to review the changes before merging them in your codebase.

# License

`accent-cli` is © 2019 [Mirego](http://www.mirego.com) and may be freely distributed under the [New BSD license](http://opensource.org/licenses/BSD-3-Clause).  See the [`LICENSE.md`](https://github.com/mirego/accent-cli/blob/master/LICENSE.md) file.
# About Mirego

[Mirego](http://mirego.com) is a team of passionate people who believe that work is a place where you can innovate and have fun. We’re a team of [talented people](http://life.mirego.com) who imagine and build beautiful Web and mobile applications. We come together to share ideas and [change the world](http://mirego.org).

We also [love open-source software](http://open.mirego.com) and we try to give back to the community as much as we can.
