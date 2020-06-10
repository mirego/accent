-module(lint@checks@same_trailing_character).
-compile(no_auto_import).

-export([applicable/1, check/1]).

applicable(Entry) ->
    gleam@bool:negate(erlang:element(4, Entry)).

check(Entry) ->
    MasterWithTrailing = lint@helpers@regex:match(
        erlang:element(3, Entry),
        <<"(\\.|:)$"/utf8>>,
        []
    ),
    ValueWithTrailing = lint@helpers@regex:match(
        erlang:element(2, Entry),
        <<"(\\.|:)$"/utf8>>,
        []
    ),
    Mismatch = case {MasterWithTrailing, ValueWithTrailing} of
        {{match, _}, nomatch} ->
            true;

        {nomatch, {match, _}} ->
            true;

        _ ->
            false
    end,
    case Mismatch of
        true ->
            ValueTrailingCharacter = gleam@string:slice(
                erlang:element(2, Entry),
                -1,
                1
            ),
            MasterTrailingCharacter = gleam@string:slice(
                erlang:element(3, Entry),
                -1,
                1
            ),
            case ValueTrailingCharacter /= MasterTrailingCharacter of
                true ->
                    [{same_trailing_character, erlang:element(2, Entry), none}];

                _ ->
                    []
            end;

        _ ->
            []
    end.
