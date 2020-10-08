import gleam/bool
import gleam/regex
import gleam/option.{None}
import lint/types.{Entry, FirstLetterCase}

fn message(text) {
  FirstLetterCase(text: text, replacement: None)
}

fn starts_with_letter(text) {
  let Ok(re) = regex.from_string("a")
  regex.check(re, text)
}

fn starts_with_capitalized_letter(text) {
  let Ok(re) = regex.from_string("^\[A-Z\]")
  regex.check(re, text)
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
