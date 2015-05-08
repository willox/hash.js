local persist = true

local persistHooks = {}
local hooks = {}

local function Add( event, id, callback )

	if ( type( callback ) ~= "function" ) then
		error( "bad argument #3 to 'Add' (function expected, got " .. type( callback ) .. ")", 2 )
	end

	if persistHooks[ event ] and persistHooks[ event ][ id ] then
		error( "attempt to override persistent hook", 2 )
	end

	hooks[ event ] = hooks[ event ] or {}
	hooks[ event ][ id ] = callback

	if persist then
		persistHooks[ event ] = persistHooks[ event ] or {}
		persistHooks[ event ][ id ] = true
	end

end

local function Remove( event, id )

	if not hooks[ event ] then
		error( "attempt to remove non-existent hook", 2 )
	end

	if persistHooks[ event ] and persistHooks[ event ][ id ] then
		error( "attempt to persistent hook", 2 )
	end

	hooks[ event ][ id ] = nil

end

local function Call( event, ... )

	if not hooks[ event ] then
		return
	end

	for k, v in pairs( hooks[ event ] ) do
		
		local success, err = pcall( v, ... )
		
		if not success then
			
			print( err )

			hooks[ event ][ id ] = nil -- Even remove persistent hooks
			
		end

	end

end

local function GetTable()

	local ret = {}

	for k, v in pairs( hooks ) do

		ret[ k ] = v

	end

	return ret

end

local function StopPersist()

	persist = false

end

return {
	Add = Add,
	Remove = Remove,
	RemoveAll = RemoveAll,
	Call = Call,
	GetTable = GetTable,
	StopPersist = StopPersist
}
