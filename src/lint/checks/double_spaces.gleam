import gleam/string
import gleam/option.{Some}
import lint/types.{DoubleSpaces, Entry, Message, MessageReplacement}

fn message(entry: Entry, text) {
  DoubleSpaces(
    text: entry.value,
    replacement: Some(MessageReplacement(value: text, label: text)),
  )
}

pub fn applicable(_entry: Entry) {
  True
}

pub fn check(entry: Entry) -> List(Message) {
  let fixed_text = string.replace(entry.value, each: "  ", with: " ")

  case fixed_text != entry.value {
    True -> [message(entry, fixed_text)]
    False -> []
  }
}
