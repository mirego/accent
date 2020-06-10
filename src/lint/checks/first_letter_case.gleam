import gleam/bool
import gleam/option.{None}
import lint/helpers/regex.{Match, Nomatch}
import lint/types.{Entry, FirstLetterCase}

fn message(text) {
  FirstLetterCase(text: text, replacement: None)
}

fn starts_with_letter(text) {
  case regex.match(text, "^\[a-zA-Z\]", []) {
    Match(_) -> True
    _ -> False
  }
}

fn starts_with_capitalized_letter(text) {
  case regex.match(text, "^\[A-Z\]", []) {
    Match(_) -> True
    _ -> False
  }
}

pub fn applicable(entry: Entry) {
  bool.negate(entry.is_master)
}

pub fn check(entry: Entry) {
  let value_letter = starts_with_letter(entry.value)
  let master_letter = starts_with_letter(entry.master_value)
  let value_trailing = starts_with_capitalized_letter(entry.value)
  let master_trailing = starts_with_capitalized_letter(entry.master_value)

  case tuple(value_letter, master_letter, value_trailing, master_trailing) {
    tuple(True, True, False, True) -> [message(entry.value)]
    tuple(True, True, True, False) -> [message(entry.value)]
    _ -> []
  }
}
