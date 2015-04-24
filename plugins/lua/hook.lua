local hooks = {}

local function Add( event, id, callback )

	if ( type( callback ) ~= "function" ) then
		error( "bad argument #3 to 'Add' (function expected got " .. type( callback ) .. ")", 2 )
	end

	hooks[ event ] = hooks[ event ] or {}
	hooks[ event ][ id ] = callback

end

local function Remove( event, id )

	if not hooks[ event ] then
		return
	end

	hooks[ event ][ id ] = nil

end

local function RemoveAll()

	hooks = {}

end

local function Call( event, ... )

	if not hooks[ event ] then
		return
	end

	for k, v in pairs( hooks[ event ] ) do
		
		local success, err = pcall( v, ... )
		
		if not success then
			hooks[ event ][ k ] = nil
		end

	end

end

function GetTable()

	local ret = {}

	for k, v in pairs( hooks ) do

		ret[ k ] = v

	end

	return ret

end

return {
	Add = Add,
	Remove = Remove,
	RemoveAll = RemoveAll,
	Call = Call,
	GetTable = GetTable
}
