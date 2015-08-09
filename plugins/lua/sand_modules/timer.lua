local tostring = require "stostring"
local scall    = require "scall"
local timers = {}
local simple_timers = {}

local function CreateSimpleTimerPacket( id, delay )
	local header = HEADERSTART .. "SimpleTimer," .. 
		PacketSafe(id, 2) .. ":" .. PacketSafe(delay, 3) .. HEADEREND
	return header
end

local function CreateTimerPacket( id, delay, reps )
	local header = HEADERSTART .. "Timer," .. 
		PacketSafe(id, 2) .. ":" .. PacketSafe(delay, 3) .. HEADEREND ..
		PacketSafe(reps, 4)
	return header
end

local simple_index = 1;

local function Simple( delay, callback )

	if ( type( callback ) ~= "function" ) then
		error( "bad argument #2 to 'Simple' (function expected, got " .. type( callback ) .. ")", 2 )
	end

	simple_timers[simple_index] = callback;
	
	writepacket(CreateSimpleTimerPacket(simple_index, delay));
	writepacket(EOF);
	
	simple_index = simple_index + 1;

end

function SimpleTimerCallback( id )
	local f = simple_timers[id];
	simple_timers[id] = nil;
	if(f) then
		f();
	end
end

local function Create( id, delay, reps, callback )
	
	id = tostring(id); -- implementation limitation: all ids must be strings

	if ( type( delay ) ~= "number" ) then
		error( "bad argument #2 to 'Create' (number expected, got " .. type( delay ) .. ")", 2 )
	end

	if ( type( reps ) ~= "number" ) then
		error( "bad argument #3 to 'Create' (number expected, got " .. type( reps ) .. ")", 2 )
	end
	
	if ( reps < 0 ) then
		error( "bad argument #3 to 'Create' (number is less than zero)", 2 )
	end

	if ( type( callback ) ~= "function" ) then
		error( "bad argument #4 to 'Create' (function expected, got " .. type( callback ) .. ")", 2 )
	end

	timers[ id ] = callback
	
	writepacket(CreateTimerPacket(id, delay, reps));
	writepacket(EOF);

end

function TimerCallback( id, remove )
	local f = timers[id];
	if(remove) then timers[id] = nil; end
	if(f) then
		f();
	end
end

local function Remove( id )

	timers[ id ] = nil
	
	writepacket(CreateTimerPacket(id, delay, -1));
	writepacket(EOF);

end

local function RemoveAll()
	
	for k,v in pairs( timers ) do
		writepacket(CreateTimerPacket(id, delay, -1));
		writepacket(EOF);
	end
	
	timers = {}
	
	simple_timers = {}

end

return {
	Simple		= Simple,
	Create		= Create,
	Remove		= Remove,
	RemoveAll	= RemoveAll,
}
