import gleam/io
import gleam/bool
import gleam/regex.{Options}
import gleam/string
import gleam/option.{None, Some}
import lint/types.{Entry, FirstLetterCase, MessageReplacement}

fn message(entry: Entry, text) {
  FirstLetterCase(
    text: entry.value,
    replacement: Some(MessageReplacement(value: text, label: text)),
  )
}

fn starts_with_letter(text) {
  let options = Options(case_insensitive: True, multi_line: False)
  let Ok(re) = regex.compile("^[A-Z]", with: options)
  regex.check(re, text)
}

fn starts_with_capitalized_letter(text) {
  let options = Options(case_insensitive: False, multi_line: False)
  let Ok(re) = regex.compile("^[A-Z]", with: options)
  regex.check(re, text)
}

pub fn applicable(entry: Entry) {
  bool.negate(entry.is_master)
}

pub fn check(entry: Entry) {
  let value_letter = starts_with_letter(entry.value)
  let master_letter = starts_with_letter(entry.master_value)
  let value_leading = starts_with_capitalized_letter(entry.value)
  let master_leading = starts_with_capitalized_letter(entry.master_value)

  case tuple(value_letter, master_letter, value_leading, master_leading) {
    tuple(True, True, False, True) -> {
      let [first_letter, ..rest] = string.to_graphemes(entry.value)
      [message(entry, string.concat([string.uppercase(first_letter), ..rest]))]
    }
    tuple(True, True, True, False) -> {
      let [first_letter, ..rest] = string.to_graphemes(entry.value)
      [message(entry, string.concat([string.lowercase(first_letter), ..rest]))]
    }
    _ -> []
  }
}
