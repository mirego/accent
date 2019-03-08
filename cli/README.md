Accent CLI
======

[![Version](https://img.shields.io/npm/v/accent-cli.svg)](https://npmjs.org/package/accent-cli)
[![Build Status](https://img.shields.io/travis/v/accent-cli.svg?branch=master)](https://travis-ci.com/mirego/accent-cli)

<!-- toc -->
* [Usage](#usage)
* [Configuration](#configuration)
* [Commands](#commands)
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
accent-cli/0.6.0 darwin-x64 node-v9.5.0
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
      "language": "fr",
      "format": "json",
      "source": "localization/fr/*.json",
      "target": "localization/%slug%/%original_file_name%.json",
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
* [`accent help [COMMAND]`](#accent-help-command)
* [`accent jipt PSEUDOLANGUAGENAME`](#accent-jipt-pseudolanguagename)
* [`accent stats`](#accent-stats)
* [`accent sync`](#accent-sync)

## `accent export`

Export files from Accent and write them to your local filesystem

```
USAGE
  $ accent export

OPTIONS
  --order-by=index|key-asc  [default: index] Will be used in the export call as the order of the keys

EXAMPLE
  $ accent export
```

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

## `accent stats`

Fetch stats from the API and display it beautifully

```
USAGE
  $ accent stats

EXAMPLE
  $ accent stats
```

## `accent sync`

Sync files in Accent and write them to your local filesystem

```
USAGE
  $ accent sync

OPTIONS
  --add-translations                Add translations in Accent to help translators if you already have translated
                                    strings

  --merge-type=smart|passive|force  [default: smart] Will be used in the add translations call as the "merge_type" param

  --order-by=index|key-asc          [default: index] Will be used in the export call as the order of the keys

  --sync-type=smart|passive         [default: smart] Will be used in the sync call as the "sync_type" param

  --write                           Write the file from the export _after_ the operation

EXAMPLE
  $ accent sync
```
<!-- commandsstop -->

# License

`accent-cli` is © 2019 [Mirego](http://www.mirego.com) and may be freely distributed under the [New BSD license](http://opensource.org/licenses/BSD-3-Clause).  See the [`LICENSE.md`](https://github.com/mirego/accent-cli/blob/master/LICENSE.md) file.

# About Mirego

[Mirego](http://mirego.com) is a team of passionate people who believe that work is a place where you can innovate and have fun. We’re a team of [talented people](http://life.mirego.com) who imagine and build beautiful Web and mobile applications. We come together to share ideas and [change the world](http://mirego.org).

We also [love open-source software](http://open.mirego.com) and we try to give back to the community as much as we can.
