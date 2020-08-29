import gleam/string
import gleam/option.{Some}
import lint/helpers/format
import lint/types.{Entry, MessageReplacement, TrailingSpace}

fn message(entry: Entry, text) {
  TrailingSpace(
    text: format.display_trailing_text(entry.value),
    replacement: Some(MessageReplacement(
      value: text,
      label: format.display_trailing_text(text),
    )),
  )
}

pub fn applicable(_entry: Entry) {
  True
}

pub fn check(entry: Entry) {
  let fixed_text = string.trim_right(entry.value)

  case fixed_text != entry.value {
    True -> [message(entry, fixed_text)]
    False -> []
  }
}
