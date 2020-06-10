-module(lint).
-compile(no_auto_import).

-export([lint/1]).

checks() ->
    [{fun lint@checks@leading_spaces:check/1,
      fun lint@checks@leading_spaces:applicable/1},
     {fun lint@checks@double_spaces:check/1,
      fun lint@checks@double_spaces:applicable/1},
     {fun lint@checks@first_letter_case:check/1,
      fun lint@checks@first_letter_case:applicable/1},
     {fun lint@checks@same_trailing_character:check/1,
      fun lint@checks@same_trailing_character:applicable/1},
     {fun lint@checks@three_dots_ellipsis:check/1,
      fun lint@checks@three_dots_ellipsis:applicable/1},
     {fun lint@checks@trailing_space:check/1,
      fun lint@checks@trailing_space:applicable/1},
     {fun lint@checks@placeholder_count:check/1,
      fun lint@checks@placeholder_count:applicable/1},
     {fun lint@checks@url_count:check/1,
      fun lint@checks@url_count:applicable/1}].

lint(Entries) ->
    gleam@list:map(
        Entries,
        fun(Entry) ->
            gleam@list:fold(
                checks(),
                Entry,
                fun(CheckModule, Entry1) -> {Check, Applicable} = CheckModule,
                    case Applicable(Entry1) of
                        false ->
                            Entry1;

                        true ->
                            {entry,
                             erlang:element(2, Entry1),
                             erlang:element(3, Entry1),
                             erlang:element(4, Entry1),
                             gleam@list:append(
                                 erlang:element(5, Entry1),
                                 Check(Entry1)
                             )}
                    end end
            )
        end
    ).
