-module(lint@checks@three_dots_ellipsis).
-compile(no_auto_import).

-export([applicable/1, check/1]).

message(Entry, Text) ->
    {three_dot_ellipsis,
     erlang:element(2, Entry),
     {some, {message_replacement, Text, Text}}}.

applicable(_) ->
    true.

check(Entry) ->
    FixedText = gleam@string:replace(
        erlang:element(2, Entry),
        <<"..."/utf8>>,
        <<"…"/utf8>>
    ),
    case FixedText /= erlang:element(2, Entry) of
        true ->
            [message(Entry, FixedText)];

        false ->
            []
    end.
