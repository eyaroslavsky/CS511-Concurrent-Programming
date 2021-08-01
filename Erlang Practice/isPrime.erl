-module(isPrime).
-compile(export_all).

start() ->
	S = spawn(?MODULE, server, []),
	[spawn(?MODULE, client, [S])].
	
server() ->
	receive
		{From, N} -> 
			serverLoop(From, N, N-1)
	end.
	
serverLoop(From, N, 1) ->
	From!{self(), true},
	server();
serverLoop(From, N, CurrNum) ->
	case N rem CurrNum of
		0 -> From!{self(), false},
			server();
		_ -> serverLoop(From, N, CurrNum - 1)
	end.
	
client(S) ->
	S!{self(), 2},
	receive
		{From, true} -> io:format("true");
		{From, false} -> io:format("false")
	end.

