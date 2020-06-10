import gleam/option.{Option}

pub type MessageReplacement {
  MessageReplacement(value: String, label: String)
}

pub type Message {
  FirstLetterCase(text: String, replacement: Option(MessageReplacement))
  LeadingSpaces(text: String, replacement: Option(MessageReplacement))
  DoubleSpaces(text: String, replacement: Option(MessageReplacement))
  ThreeDotEllipsis(text: String, replacement: Option(MessageReplacement))
  TrailingSpace(text: String, replacement: Option(MessageReplacement))
  SameTrailingCharacter(text: String, replacement: Option(MessageReplacement))
  PlaceholderCount(text: String, replacement: Option(MessageReplacement))
  URLCount(text: String, replacement: Option(MessageReplacement))
}

pub type Entry {
  Entry(
    value: String,
    master_value: String,
    is_master: Bool,
    messages: List(Message),
  )
}
