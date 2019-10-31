# Changelog

## 0.8.0

### Breaking changes

- `language` key is no longer supported in `files` items since the `language` is always the master language.

### Soft Deprecations

- Use `%document_path%` placeholder instead of `%original_file_name%` as it better reflect Accent nomenclature.

### Features

- `namePattern` key is used to force either `parentDirectory`, `fullDirectory` or `file` config to use as `documentPath` sent to Accent.
- Directories are now created on-the-fly when using the `--write` flag.
- New useful logs
