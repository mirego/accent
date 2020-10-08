import gleam/bool
import gleam/string
import gleam/list
import gleam/option.{None}
import gleam/regex
import lint/helpers/format
import lint/types.{Entry, URLCount}

fn message(entry: Entry) {
  URLCount(text: format.display_leading_text(entry.value), replacement: None)
}

fn match_url(text) {
  let Ok(url_regex) = regex.from_string("https?://([a-z0-9]+\\.)?[a-z0-9]+\\.")

  regex.scan(url_regex, text)
}

pub fn applicable(entry: Entry) {
  bool.negate(entry.is_master)
}

pub fn check(entry: Entry) {
  let master_matches = match_url(entry.master_value)
  let value_matches = match_url(entry.value)

  case list.length(master_matches) == list.length(value_matches) {
    True -> []
    False -> [message(entry)]
  }
}
