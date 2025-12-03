-module(day3).
-export([main/1]).

main(K) ->
    {ok, Binary} = file:read_file("./joltage.txt"),
    Lines = binary:split(Binary, <<"\n">>, [global, trim]),
    lists:foldl(fun(Line, Sum) ->
        Sum + max_from_line(Line, K)
    end, 0, Lines).

max_from_line(Line, K) ->
    Digits = [binary_to_integer(<<D>>) || <<D>> <= Line],
    Picked = pick(Digits, K, 1),
    list_to_integer(lists:flatten([integer_to_list(D) || D <- Picked])).

pick(_, 0, _) ->
    [];
pick(Digits, K, Start) ->
    Len = length(Digits),
    End = Len - K + 1,
    {Best, Pos} = find_best(Digits, Start, End),
    [Best | pick(Digits, K - 1, Pos + 1)].

find_best(Digits, Start, End) ->
    Sub = lists:sublist(Digits, Start, End - Start + 1),
    Best = lists:max(Sub),
    Remaining = lists:nthtail(Start - 1, Digits),
    Pos = find_pos(Remaining, Best, Start),
    {Best, Pos}.

find_pos([H|_], Digit, Pos) when H == Digit ->
    Pos;
find_pos([_|T], Digit, Pos) ->
    find_pos(T, Digit, Pos + 1).
