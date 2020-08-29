import gleam/string

fn pad_max_length(
  text: String,
  at_index: Int,
  to_index: Int,
  fun: fn(String, Int, String) -> String,
) -> String {
  case string.length(text) > 12 {
    False -> text
    True ->
      text
      |> string.slice(at_index: at_index, length: to_index)
      |> fun(13, "…")
  }
}

pub fn display_trailing_text(text: String) -> String {
  pad_max_length(
    text,
    string.length(text) - 12,
    string.length(text),
    string.pad_left,
  )
}

pub fn display_leading_text(text: String) -> String {
  pad_max_length(text, 0, string.length(text) - 1, string.pad_right)
}
