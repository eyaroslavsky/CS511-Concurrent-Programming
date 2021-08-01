-module(turnstile).
-compile(export_all).

start(N) ->
	C = spawn(?MODULE, counter_server, [0]),
	[spawn(?MODULE, turnstile, [C, 50]) || _ <- lists:seq(1, N)],
	C.
	
counter_server(State) ->
	receive
		{bump} -> counter_server(State + 1);
		{read, From} -> State
	end.

turnstile(C, 0) ->
	C!{read, self()};
turnstile(C, N) when N>0 ->
	C!{bump},
	turnstile(C, N - 1).