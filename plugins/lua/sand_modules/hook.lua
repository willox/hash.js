local persist = true
local javascript_call = true
local override_callstate = true

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
		error( "attempt to remove persistent hook", 2 )
	end

	hooks[ event ][ id ] = nil

end

local function Call( event, ... )
	
	local before = javascript_call
	
	if not override_callstate then
		javascript_call = false
	end
	
	override_callstate = false

	if not hooks[ event ] then
		
		javascript_call = before
		
		return
	end

	for k, v in pairs( hooks[ event ] ) do
		
		local success, err = pcall( v, ... )
		
		if not success then
			
			print( err )

			hooks[ event ][ k ] = nil -- Even remove persistent hooks
			
		end

	end
	
	javascript_call = before

end

local function GetTable()
	
	local before = javascript_call
	
	javascript_call = false

	local ret = {}

	for k, v in pairs( hooks ) do

		ret[ k ] = v

	end
	
	javascript_call = before

	return ret

end

local function StopPersist()

	persist = false

end

local function CalledFromSandbox()
	
	return not javascript_call
	
end

-- called from javascript

function HookCall( event, ... )
	
	override_callstate = true
	
	javascript_call = true
	
	Call ( event, ... )
	
	javascript_call = false
	
end

return {
	Add = Add,
	Remove = Remove,
	RemoveAll = RemoveAll,
	Call = Call,
	GetTable = GetTable,
	StopPersist = StopPersist,
	CalledFromSandbox = CalledFromSandbox,
}
