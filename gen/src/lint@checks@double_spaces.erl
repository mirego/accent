-module(lint@checks@double_spaces).
-compile(no_auto_import).

-export([applicable/1, check/1]).

message(Entry, Text) ->
    {double_spaces,
     erlang:element(2, Entry),
     {some, {message_replacement, Text, Text}}}.

applicable(_) ->
    true.

check(Entry) ->
    FixedText = gleam@string:replace(
        erlang:element(2, Entry),
        <<"  "/utf8>>,
        <<" "/utf8>>
    ),
    case FixedText /= erlang:element(2, Entry) of
        true ->
            [message(Entry, FixedText)];

        false ->
            []
    end.
