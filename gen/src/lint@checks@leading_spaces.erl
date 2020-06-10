-module(lint@checks@leading_spaces).
-compile(no_auto_import).

-export([applicable/1, check/1]).

message(Entry, Text) ->
    {leading_spaces,
     erlang:element(2, Entry),
     {some, {message_replacement, Text, Text}}}.

applicable(_) ->
    true.

check(Entry) ->
    FixedText = gleam@string:trim_left(erlang:element(2, Entry)),
    case FixedText /= erlang:element(2, Entry) of
        true ->
            [message(Entry, FixedText)];

        false ->
            []
    end.
