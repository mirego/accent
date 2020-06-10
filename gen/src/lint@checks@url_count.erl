-module(lint@checks@url_count).
-compile(no_auto_import).

-export([applicable/1, check/1]).

message(Entry) ->
    {url_count,
     lint@helpers@format:display_leading_text(erlang:element(2, Entry)),
     none}.

match_url(Text) ->
    UrlRegex = <<"https?://([a-z0-9]+\\.)?[a-z0-9]+\\."/utf8>>,
    lint@helpers@regex:match(
        Text,
        UrlRegex,
        [gleam@atom:create_from_string(<<"global"/utf8>>)]
    ).

applicable(Entry) ->
    gleam@bool:negate(erlang:element(4, Entry)).

check(Entry) ->
    ValueTrailing = match_url(erlang:element(2, Entry)),
    MasterTrailing = match_url(erlang:element(3, Entry)),
    case {MasterTrailing, ValueTrailing} of
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
