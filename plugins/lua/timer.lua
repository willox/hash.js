local timers = {}
local simple_timers = {}
local processing = false

local function Simple( delay, callback )

	if ( processing ) then
		error( "can't recursively create timers", 2 )
	end

	if ( type( callback ) ~= "function" ) then
		error( "bad argument #2 to 'Simple' (function expected got " .. type( callback ) .. ")", 2 )
	end

	table.insert( simple_timers, {

		WhenToGo	= os.clock() + delay,
		Callback	= callback

	} )

end

local function Create( id, delay, reps, callback )

	if ( processing ) then
		error( "can't recursively create timers", 2 )
	end

	if ( type( delay ) ~= "number" ) then
		error( "bad argument #2 to 'Create' (number expected got " .. type( delay ) .. ")", 2 )
	end

	if ( type( reps ) ~= "number" ) then
		error( "bad argument #3 to 'Create' (number expected got " .. type( reps ) .. ")", 2 )
	end

	if ( type( callback ) ~= "function" ) then
		error( "bad argument #4 to 'Create' (function expected got " .. type( callback ) .. ")", 2 )
	end

	timers[ id ] = {

		WhenToGo	= os.clock() + delay,
		Callback	= callback,
		Repetitions	= reps,
		Delay		= delay

	}

end

local function Remove( id )

	timers[ id ] = nil

end

local function RemoveAll()

	timers = {}
	simple_timers = {}

end

local function Tick()

	processing = true

	for i = #simple_timers, 1, -1 do

		local v = simple_timers[ i ]

		if v.WhenToGo <= os.clock() then

			table.remove( simple_timers, i )

			local success, err = pcall( v.Callback )

			if not success then

				print( err )

			end

		end

	end

	for k, v in pairs( timers ) do

		if v.WhenToGo <= os.clock() then

			if v.Repetitions ~= 0 then
				v.Repetitions = v.Repetitions - 1

				if v.Repetitions == 0 then
					timers[ k ] = nil
				end
			end

			local success, err = pcall( v.Callback )

			if not success then

				print( err )

				timers[ k ] = nil

			end

			v.WhenToGo = os.clock() + v.Delay

		end			

	end

	processing = false

end

return {
	Simple		= Simple,
	Create		= Create,
	Remove		= Remove,
	RemoveAll	= RemoveAll,
	Tick		= Tick,
}