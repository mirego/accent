import gleam/string
import gleam/bool
import gleam/atom
import gleam/list
import gleam/option.{None}
import lint/helpers/format
import lint/helpers/regex.{Match, Nomatch}
import lint/types.{Entry, PlaceholderCount}

fn message(entry: Entry) {
  PlaceholderCount(
    text: format.display_leading_text(entry.value),
    replacement: None,
  )
}

fn match_placeholders(text) {
  let placeholder_regex = "(\{\{\\w+\}\})|(%\{\\w+\})"

  regex.match(text, placeholder_regex, [atom.create_from_string("global")])
}

pub fn applicable(entry: Entry) {
  bool.negate(entry.is_master)
}

pub fn check(entry: Entry) {
  let value_placeholders = match_placeholders(entry.value)
  let master_placeholders = match_placeholders(entry.master_value)

  case tuple(master_placeholders, value_placeholders) {
    tuple(Match(_), Nomatch) -> [message(entry)]
    tuple(Nomatch, Match(_)) -> [message(entry)]
    tuple(Match(master_matches), Match(value_matches)) ->
      case list.length(master_matches) == list.length(value_matches) {
        True -> []
        False -> [message(entry)]
      }
    _ -> []
  }
}
