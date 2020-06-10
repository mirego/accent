import gleam/atom.{Atom}

pub type MatchResult {
  Match(List(tuple(Int, Int)))
  Nomatch
}

pub external fn match(String, String, List(Atom)) -> MatchResult =
  "re" "run"
