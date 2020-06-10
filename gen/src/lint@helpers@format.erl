-module(lint@helpers@format).
-compile(no_auto_import).

-export([display_trailing_text/1, display_leading_text/1]).

pad_max_length(Text, AtIndex, ToIndex, Fun) ->
    case gleam@string:length(Text) > 12 of
        false ->
            Text;

        true ->
            Fun(gleam@string:slice(Text, AtIndex, ToIndex), 13, <<"…"/utf8>>)
    end.

display_trailing_text(Text) ->
    pad_max_length(
        Text,
        gleam@string:length(Text)
        - 12,
        gleam@string:length(Text),
        fun gleam@string:pad_left/3
    ).

display_leading_text(Text) ->
    pad_max_length(
        Text,
        0,
        gleam@string:length(Text)
        - 1,
        fun gleam@string:pad_right/3
    ).
