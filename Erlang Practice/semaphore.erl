-module(sem).
-compile(export_all).

start(Permits) ->
	spawn(?MODULE, semaphore, [Permits]).
	
	
semaphore(0) ->
	
semaphore(N) when N>0 ->


%%Make sure ab is always printed after cd
client1(S) ->
	io:format("a"),
	io:format("b").
	
client2(S) ->
	io:format("c"),
	io:formate("d").