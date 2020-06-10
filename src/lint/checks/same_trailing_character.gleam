import gleam/io
import gleam/bool
import gleam/string
import gleam/option.{None}
import lint/helpers/regex.{Match, Nomatch}
import lint/types.{Entry, SameTrailingCharacter}

pub fn applicable(entry: Entry) {
  bool.negate(entry.is_master)
}

pub fn check(entry: Entry) {
  let master_with_trailing = regex.match(entry.master_value, "(\\.|:)$", [])
  let value_with_trailing = regex.match(entry.value, "(\\.|:)$", [])

  let mismatch = case tuple(master_with_trailing, value_with_trailing) {
    tuple(Match(_), Nomatch) -> True
    tuple(Nomatch, Match(_)) -> True
    _ -> False
  }

  case mismatch {
    True -> {
      let value_trailing_character = string.slice(entry.value, -1, 1)
      let master_trailing_character = string.slice(entry.master_value, -1, 1)
      case value_trailing_character != master_trailing_character {
        True -> [SameTrailingCharacter(text: entry.value, replacement: None)]
        _ -> []
      }
    }
    _ -> []
  }
}
