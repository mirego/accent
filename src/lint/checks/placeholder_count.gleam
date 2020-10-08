import gleam/string
import gleam/bool
import gleam/atom
import gleam/list
import gleam/option.{None}
import gleam/regex
import lint/helpers/format
import lint/types.{Entry, PlaceholderCount}

fn message(entry: Entry) {
  PlaceholderCount(
    text: format.display_leading_text(entry.value),
    replacement: None,
  )
}

fn match_placeholders(text) {
  let Ok(placeholder_regex) = regex.from_string("(\{\{\\w+\}\})|(%\{\\w+\})")

  regex.scan(placeholder_regex, text)
}

pub fn applicable(entry: Entry) {
  bool.negate(entry.is_master)
}

pub fn check(entry: Entry) {
  let master_matches = match_placeholders(entry.master_value)
  let value_matches = match_placeholders(entry.value)

  case list.length(master_matches) == list.length(value_matches) {
    True -> []
    False -> [message(entry)]
  }
}
