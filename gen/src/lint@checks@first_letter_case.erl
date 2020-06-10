-module(lint@checks@first_letter_case).
-compile(no_auto_import).

-export([applicable/1, check/1]).

message(Text) ->
    {first_letter_case, Text, none}.

starts_with_letter(Text) ->
    case lint@helpers@regex:match(Text, <<"^\[a-zA-Z\]"/utf8>>, []) of
        {match, _} ->
            true;

        _ ->
            false
    end.

starts_with_capitalized_letter(Text) ->
    case lint@helpers@regex:match(Text, <<"^\[A-Z\]"/utf8>>, []) of
        {match, _} ->
            true;

        _ ->
            false
    end.

applicable(Entry) ->
    gleam@bool:negate(erlang:element(4, Entry)).

check(Entry) ->
    ValueLetter = starts_with_letter(erlang:element(2, Entry)),
    MasterLetter = starts_with_letter(erlang:element(3, Entry)),
    ValueTrailing = starts_with_capitalized_letter(erlang:element(2, Entry)),
    MasterTrailing = starts_with_capitalized_letter(erlang:element(3, Entry)),
    case {ValueLetter, MasterLetter, ValueTrailing, MasterTrailing} of
        {true, true, false, true} ->
            [message(erlang:element(2, Entry))];

        {true, true, true, false} ->
            [message(erlang:element(2, Entry))];

        _ ->
            []
    end.
