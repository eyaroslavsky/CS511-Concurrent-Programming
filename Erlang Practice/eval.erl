-module(eval).
-compile(export_all).

e1() ->
	{add,
		{const, 3},
		{divi,
			{const, 4},
			{const, 2}}}.

calc({const, N}) ->
	{val, N};
calc({add, E1, E2}) ->
	{val, N1} = calc(E1),
	{val, N2} = calc(E2),
	{val, N1 + N2};
calc({sub, E1, E2}) ->
	{val, N1} = calc(E1),
	{val, N2} = calc(E2),
	{val, N1 - N2};
calc({mul, E1, E2}) ->
	{val, N1} = calc(E1),
	{val, N2} = calc(E2),
	{val, N1 * N2};
calc({divi, E1, E2}) ->
	{val, N1} = calc(E1),
	{val, N2} = calc(E2),
	{val, N1 div N2}.