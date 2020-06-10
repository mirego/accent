-module(lint@helpers@regex).
-compile(no_auto_import).

-export([match/3]).

match(A, B, C) ->
    re:run(A, B, C).
