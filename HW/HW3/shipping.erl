%%Edward Yaroslavsky
%%I pledge my honor that I have avided by the Stevens Honor System.

-module(shipping).
-compile(export_all).
-include_lib("./shipping.hrl").

get_ship(Shipping_State, Ship_ID) ->
    Ship = lists:keysearch(Ship_ID, #ship.id, Shipping_State#shipping_state.ships),
	case Ship of
		{value, ShipVal} -> ShipVal;
		_ -> error
	end.

get_container(Shipping_State, Container_ID) ->
    Container = lists:keysearch(Container_ID, #container.id, Shipping_State#shipping_state.containers),
	case Container of
		{value, ContainerVal} -> ContainerVal;
		_ -> error
	end.

get_port(Shipping_State, Port_ID) ->
    Port = lists:keysearch(Port_ID, #port.id, Shipping_State#shipping_state.ports),
	case Port of
		{value, PortVal} -> PortVal;
		_ -> error
	end.

get_occupied_docks(Shipping_State, Port_ID) ->
    Dock_List = Shipping_State#shipping_state.ship_locations,
	get_occupied_docks_helper(Dock_List, Port_ID).
	
get_occupied_docks_helper([], Port_ID) ->
	[];
get_occupied_docks_helper(Dock_List, Port_ID) ->
	[H | T] = Dock_List,
	{Port, Dock, Ship} = H, 
	case Port of
		Port_ID -> [Dock | get_occupied_docks_helper(T, Port_ID)];
		_ -> get_occupied_docks_helper(T, Port_ID)
	end.
	
get_ship_location(Shipping_State, Ship_ID) ->
    Locations = Shipping_State#shipping_state.ship_locations,
	get_ship_location_helper(Locations, Ship_ID).
	
get_ship_location_helper([], Ship_ID) ->
	error;
get_ship_location_helper(Locations, Ship_ID) ->
	[H | T] = Locations,
	{Port, Dock, Ship} = H,
	case Ship of 
		Ship_ID -> {Port, Dock};
		_ -> get_ship_location_helper(T, Ship_ID)
	end.

get_container_weight(Shipping_State, Container_IDs) ->
    get_container_weight_helper(Shipping_State, Container_IDs, 0).
	
get_container_weight_helper(_, [], WeightVal) ->
	WeightVal;
get_container_weight_helper(Shipping_State, ID_List, WeightVal) ->
	[H | T] = ID_List,
	Container = get_container(Shipping_State, H),
	case Container of
		#container{id = ID, weight = N} -> get_container_weight_helper(Shipping_State, T, WeightVal + N);
		_ -> error
	end.
	
get_ship_weight(Shipping_State, Ship_ID) ->
	case maps:find(Ship_ID, Shipping_State#shipping_state.ship_inventory) of
		{ok, ID_List} -> get_container_weight(Shipping_State, ID_List);
		_ -> error
	end.

load_ship(Shipping_State, Ship_ID, Container_IDs) ->
    case is_loadable(Shipping_State, Ship_ID, Container_IDs) of
		true -> load_helper(Shipping_State, Ship_ID, Container_IDs);
		_ -> error
	end.
	
is_valid_amount_of_containers(Shipping_State, Ship_ID, Container_List) ->
	Capacity = (get_ship(Shipping_State, Ship_ID))#ship.container_cap - length(maps:get(Ship_ID, Shipping_State#shipping_state.ship_inventory)) - length(Container_List),
	Capacity >= 0.
	
is_valid_container_location(Shipping_State, Ship_ID, Container_List) ->
	{Port, Dock} = get_ship_location(Shipping_State, Ship_ID),
	Port_Inventory_List = maps:get(Port, Shipping_State#shipping_state.port_inventory),
	case is_sublist(Port_Inventory_List, Container_List) of
		true -> true;
		_ -> false
	end.

is_loadable(Shipping_State, Ship_ID, Container_List) ->
	case is_valid_amount_of_containers(Shipping_State, Ship_ID, Container_List) of
		true -> case is_valid_container_location(Shipping_State, Ship_ID, Container_List) of
					true -> true;
					_ -> false
				end;
		_ -> false
	end.
	
load_helper(Shipping_State, Ship_ID, Container_List) ->
	{Port, Dock} = get_ship_location(Shipping_State, Ship_ID),
	New_Ship_Inventory = maps:get(Ship_ID, Shipping_State#shipping_state.ship_inventory) ++ Container_List,
	New_Port_Inventory = maps:get(Port, Shipping_State#shipping_state.port_inventory) -- Container_List,
	{ok, #shipping_state{
		ships = Shipping_State#shipping_state.ships,
		containers = Shipping_State#shipping_state.containers,
		ports = Shipping_State#shipping_state.ports,
		ship_locations = Shipping_State#shipping_state.ship_locations,
		ship_inventory = maps:put(Ship_ID, New_Ship_Inventory, Shipping_State#shipping_state.ship_inventory),
		port_inventory = maps:put(Port, New_Port_Inventory, Shipping_State#shipping_state.port_inventory)
	}}.

unload_ship_all(Shipping_State, Ship_ID) ->
    case get_ship_location(Shipping_State, Ship_ID) of
		{Port, Dock} -> Container_List = maps:get(Ship_ID, Shipping_State#shipping_state.ship_inventory),
						case is_valid_to_load_port(Shipping_State, Port, Container_List) of
							true -> unload_ship_all_helper(Shipping_State, Ship_ID, Port, Container_List);
							_ -> error
						end;
		_ -> error
	end.	

is_valid_to_load_port(Shipping_State, Port_ID, Container_List) ->
	Capacity = (get_port(Shipping_State, Port_ID))#port.container_cap - length(maps:get(Port_ID, Shipping_State#shipping_state.port_inventory)) - length(Container_List),
	Capacity >= 0.
	
unload_ship_all_helper(Shipping_State, Ship_ID, Port_ID, Container_List) ->
	New_Port_Inventory = maps:get(Port_ID, Shipping_State#shipping_state.port_inventory) ++ Container_List,
	{ok, #shipping_state{
		ships = Shipping_State#shipping_state.ships,
		containers = Shipping_State#shipping_state.containers,
		ports = Shipping_State#shipping_state.ports,
		ship_locations = Shipping_State#shipping_state.ship_locations,
		ship_inventory = maps:put(Ship_ID, [], Shipping_State#shipping_state.ship_inventory),
		port_inventory = maps:put(Port_ID, New_Port_Inventory, Shipping_State#shipping_state.port_inventory)
	}}.

unload_ship(Shipping_State, Ship_ID, Container_IDs) ->
    case get_ship_location(Shipping_State, Ship_ID) of
		{Port, Dock} -> case is_valid_to_load_port(Shipping_State, Port, Container_IDs) of
							true -> case is_valid_ship_container_location(Shipping_State, Ship_ID, Container_IDs) of
										true -> unload_ship_helper(Shipping_State, Ship_ID, Port, Container_IDs);
										_ -> io:format("The given containers are not all on the same ship...~n"),
											error
									end;
							_ -> error
						end;
		_ -> error
	end.
	
is_valid_ship_container_location(Shipping_State, Ship_ID, Container_List) ->
	Ship_Inventory_List = maps:get(Ship_ID, Shipping_State#shipping_state.ship_inventory),
	case is_sublist(Ship_Inventory_List, Container_List) of
		true -> true;
		_ -> false
	end.
	
unload_ship_helper(Shipping_State, Ship_ID, Port_ID, Container_List) ->
	New_Ship_Inventory = maps:get(Ship_ID, Shipping_State#shipping_state.ship_inventory) -- Container_List,
	New_Port_Inventory = maps:get(Port_ID, Shipping_State#shipping_state.port_inventory) ++ Container_List,
	{ok, #shipping_state{
		ships = Shipping_State#shipping_state.ships,
		containers = Shipping_State#shipping_state.containers,
		ports = Shipping_State#shipping_state.ports,
		ship_locations = Shipping_State#shipping_state.ship_locations,
		ship_inventory = maps:put(Ship_ID, New_Ship_Inventory, Shipping_State#shipping_state.ship_inventory),
		port_inventory = maps:put(Port_ID, New_Port_Inventory, Shipping_State#shipping_state.port_inventory)
	}}.

set_sail(Shipping_State, Ship_ID, {Port_ID, Dock}) ->
    Available_Docks = (get_port(Shipping_State, Port_ID))#port.docks -- get_occupied_docks(Shipping_State, Port_ID),
	case is_sublist(Available_Docks, [Dock]) of
		true -> New_Ship_Locations = modify_Ship_Locations(Shipping_State#shipping_state.ship_locations, Ship_ID, {Port_ID, Dock}),
				set_sail_helper(Shipping_State, New_Ship_Locations);
		_ -> error
	end.

modify_Ship_Locations([], Ship_ID, {Port_ID, Dock}) ->
	[];
modify_Ship_Locations(Ship_Locations, Ship_ID, {Port_ID, Dock}) ->
	[H | T] = Ship_Locations,
	case H of
		{_, _, Ship_ID} -> [{Port_ID, Dock, Ship_ID} | modify_Ship_Locations(T, Ship_ID, {Port_ID, Dock})];
		{PortVal, DockVal, ShipVal} -> [{PortVal, DockVal, ShipVal} | modify_Ship_Locations(T, Ship_ID, {Port_ID, Dock})]
	end.
	
set_sail_helper(Shipping_State, New_Ship_Locations) ->
	{ok, #shipping_state{
		ships = Shipping_State#shipping_state.ships,
		containers = Shipping_State#shipping_state.containers,
		ports = Shipping_State#shipping_state.ports,
		ship_locations = New_Ship_Locations,
		ship_inventory = Shipping_State#shipping_state.ship_inventory,
		port_inventory = Shipping_State#shipping_state.port_inventory
	}}.


%% Determines whether all of the elements of Sub_List are also elements of Target_List
%% @returns true is all elements of Sub_List are members of Target_List; false otherwise
is_sublist(Target_List, Sub_List) ->
    lists:all(fun (Elem) -> lists:member(Elem, Target_List) end, Sub_List).




%% Prints out the current shipping state in a more friendly format
print_state(Shipping_State) ->
    io:format("--Ships--~n"),
    _ = print_ships(Shipping_State#shipping_state.ships, Shipping_State#shipping_state.ship_locations, Shipping_State#shipping_state.ship_inventory, Shipping_State#shipping_state.ports),
    io:format("--Ports--~n"),
    _ = print_ports(Shipping_State#shipping_state.ports, Shipping_State#shipping_state.port_inventory).


%% helper function for print_ships
get_port_helper([], _Port_ID) -> error;
get_port_helper([ Port = #port{id = Port_ID} | _ ], Port_ID) -> Port;
get_port_helper( [_ | Other_Ports ], Port_ID) -> get_port_helper(Other_Ports, Port_ID).


print_ships(Ships, Locations, Inventory, Ports) ->
    case Ships of
        [] ->
            ok;
        [Ship | Other_Ships] ->
            {Port_ID, Dock_ID, _} = lists:keyfind(Ship#ship.id, 3, Locations),
            Port = get_port_helper(Ports, Port_ID),
            {ok, Ship_Inventory} = maps:find(Ship#ship.id, Inventory),
            io:format("Name: ~s(#~w)    Location: Port ~s, Dock ~s    Inventory: ~w~n", [Ship#ship.name, Ship#ship.id, Port#port.name, Dock_ID, Ship_Inventory]),
            print_ships(Other_Ships, Locations, Inventory, Ports)
    end.

print_containers(Containers) ->
    io:format("~w~n", [Containers]).

print_ports(Ports, Inventory) ->
    case Ports of
        [] ->
            ok;
        [Port | Other_Ports] ->
            {ok, Port_Inventory} = maps:find(Port#port.id, Inventory),
            io:format("Name: ~s(#~w)    Docks: ~w    Inventory: ~w~n", [Port#port.name, Port#port.id, Port#port.docks, Port_Inventory]),
            print_ports(Other_Ports, Inventory)
    end.
%% This functions sets up an initial state for this shipping simulation. You can add, remove, or modidfy any of this content. This is provided to you to save some time.
%% @returns {ok, shipping_state} where shipping_state is a shipping_state record with all the initial content.
shipco() ->
    Ships = [#ship{id=1,name="Santa Maria",container_cap=20},
              #ship{id=2,name="Nina",container_cap=20},
              #ship{id=3,name="Pinta",container_cap=20},
              #ship{id=4,name="SS Minnow",container_cap=20},
              #ship{id=5,name="Sir Leaks-A-Lot",container_cap=20}
             ],
    Containers = [
                  #container{id=1,weight=200},
                  #container{id=2,weight=215},
                  #container{id=3,weight=131},
                  #container{id=4,weight=62},
                  #container{id=5,weight=112},
                  #container{id=6,weight=217},
                  #container{id=7,weight=61},
                  #container{id=8,weight=99},
                  #container{id=9,weight=82},
                  #container{id=10,weight=185},
                  #container{id=11,weight=282},
                  #container{id=12,weight=312},
                  #container{id=13,weight=283},
                  #container{id=14,weight=331},
                  #container{id=15,weight=136},
                  #container{id=16,weight=200},
                  #container{id=17,weight=215},
                  #container{id=18,weight=131},
                  #container{id=19,weight=62},
                  #container{id=20,weight=112},
                  #container{id=21,weight=217},
                  #container{id=22,weight=61},
                  #container{id=23,weight=99},
                  #container{id=24,weight=82},
                  #container{id=25,weight=185},
                  #container{id=26,weight=282},
                  #container{id=27,weight=312},
                  #container{id=28,weight=283},
                  #container{id=29,weight=331},
                  #container{id=30,weight=136}
                 ],
    Ports = [
             #port{
                id=1,
                name="New York",
                docks=['A','B','C','D'],
                container_cap=200
               },
             #port{
                id=2,
                name="San Francisco",
                docks=['A','B','C','D'],
                container_cap=200
               },
             #port{
                id=3,
                name="Miami",
                docks=['A','B','C','D'],
                container_cap=200
               }
            ],
    %% {port, dock, ship}
    Locations = [
                 {1,'B',1},
                 {1, 'A', 3},
                 {3, 'C', 2},
                 {2, 'D', 4},
                 {2, 'B', 5}
                ],
    Ship_Inventory = #{
      1=>[14,15,9,2,6],
      2=>[1,3,4,13],
      3=>[],
      4=>[2,8,11,7],
      5=>[5,10,12]},
    Port_Inventory = #{
      1=>[16,17,18,19,20],
      2=>[21,22,23,24,25],
      3=>[26,27,28,29,30]
     },
    #shipping_state{ships = Ships, containers = Containers, ports = Ports, ship_locations = Locations, ship_inventory = Ship_Inventory, port_inventory = Port_Inventory}.
