-module(lint@checks@trailing_space).
-compile(no_auto_import).

-export([applicable/1, check/1]).

message(Entry, Text) ->
    {trailing_space,
     lint@helpers@format:display_trailing_text(erlang:element(2, Entry)),
     {some,
      {message_replacement,
       Text,
       lint@helpers@format:display_trailing_text(Text)}}}.

applicable(_) ->
    true.

check(Entry) ->
    FixedText = gleam@string:trim_right(erlang:element(2, Entry)),
    case FixedText /= erlang:element(2, Entry) of
        true ->
            [message(Entry, FixedText)];

        false ->
            []
    end.
