-module(coordinator).
-compile(export_all).

%%% 
% N is the number of threads
% M is the number of threads yet to reach the barrier
% All is the list of all PIDs involved with the barrier

coordinator(N,0,All)  ->
    implement;
coordinator(N,M,All)  ->
    implement.


client1(B) ->
    io:format("a"),
    B!{self(),arrived},
    receive
	{B,ok} ->
	    ok
    end,
    io:format("1").
	

client2(B) ->
    io:format("b"),
    B!{self(),arrived},
    receive
	{B,ok} ->
	    ok
    end,
    io:format("2").
