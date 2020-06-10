import gleam/bool
import gleam/string
import gleam/atom
import gleam/list
import gleam/option.{None}
import lint/helpers/format
import lint/helpers/regex.{Match, Nomatch}
import lint/types.{Entry, URLCount}

fn message(entry: Entry) {
  URLCount(text: format.display_leading_text(entry.value), replacement: None)
}

fn match_url(text) {
  let url_regex = "https?://([a-z0-9]+\\.)?[a-z0-9]+\\."

  regex.match(text, url_regex, [atom.create_from_string("global")])
}

pub fn applicable(entry: Entry) {
  bool.negate(entry.is_master)
}

pub fn check(entry: Entry) {
  let value_trailing = match_url(entry.value)
  let master_trailing = match_url(entry.master_value)

  case tuple(master_trailing, value_trailing) {
    tuple(Match(_), Nomatch) -> [message(entry)]
    tuple(Nomatch, Match(_)) -> [message(entry)]
    tuple(
      Match(master_matches),
      Match(value_matches),
    ) -> case list.length(master_matches) == list.length(value_matches) {
      True -> []
      False -> [message(entry)]
    }
    _ -> []
  }
}
