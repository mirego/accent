import gleam/io
import gleam/list
import gleam/map
import lint/checks/leading_spaces
import lint/checks/double_spaces
import lint/checks/first_letter_case
import lint/checks/three_dots_ellipsis
import lint/checks/same_trailing_character
import lint/checks/trailing_space
import lint/checks/placeholder_count
import lint/checks/url_count
import lint/types.{Entry}

fn checks() {
  [
    tuple(leading_spaces.check, leading_spaces.applicable),
    tuple(double_spaces.check, double_spaces.applicable),
    tuple(first_letter_case.check, first_letter_case.applicable),
    tuple(same_trailing_character.check, same_trailing_character.applicable),
    tuple(three_dots_ellipsis.check, three_dots_ellipsis.applicable),
    tuple(trailing_space.check, trailing_space.applicable),
    tuple(placeholder_count.check, placeholder_count.applicable),
    tuple(url_count.check, url_count.applicable),
  ]
}

pub fn lint(entries: List(Entry)) -> List(Entry) {
  list.map(
    entries,
    fn(entry) {
      list.fold(
        checks(),
        entry,
        fn(check_module, entry: Entry) {
          let tuple(check, applicable) = check_module

          case applicable(entry) {
            False -> entry
            True ->
              Entry(
                value: entry.value,
                master_value: entry.master_value,
                is_master: entry.is_master,
                language: entry.language,
                translation_id: entry.translation_id,
                messages: list.append(entry.messages, check(entry)),
              )
          }
        },
      )
    },
  )
}
