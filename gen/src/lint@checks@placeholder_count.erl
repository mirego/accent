-module(lint@checks@placeholder_count).
-compile(no_auto_import).

-export([applicable/1, check/1]).

message(Entry) ->
    {placeholder_count,
     lint@helpers@format:display_leading_text(erlang:element(2, Entry)),
     none}.

match_placeholders(Text) ->
    PlaceholderRegex = <<"(\{\{\\w+\}\})|(%\{\\w+\})"/utf8>>,
    lint@helpers@regex:match(
        Text,
        PlaceholderRegex,
        [gleam@atom:create_from_string(<<"global"/utf8>>)]
    ).

applicable(Entry) ->
    gleam@bool:negate(erlang:element(4, Entry)).

check(Entry) ->
    ValuePlaceholders = match_placeholders(erlang:element(2, Entry)),
    MasterPlaceholders = match_placeholders(erlang:element(3, Entry)),
    case {MasterPlaceholders, ValuePlaceholders} of
        {{match, _}, nomatch} ->
            [message(Entry)];

        {nomatch, {match, _}} ->
            [message(Entry)];

        {{match, MasterMatches}, {match, ValueMatches}} ->
            case gleam@list:length(MasterMatches)
            =:= gleam@list:length(ValueMatches) of
                true ->
                    [];

                false ->
                    [message(Entry)]
            end;

        _ ->
            []
    end.
