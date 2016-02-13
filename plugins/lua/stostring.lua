local scall = require "scall"

local function rawstring( obj )

	local meta = debug.getmetatable( obj )

	if not meta or type( meta ) ~= "table" then

		return tostring( obj )

	end

	local __tostring = rawget( meta, "__tostring" )
	rawset( meta, "__tostring", nil )

	local ret = tostring( obj )

	rawset( meta, "__tostring", __tostring )

	return ret

end

local function stostring( obj )

	--
	-- Try executing metamethods in the sandbox first
	--
	local success, str

	local meta = debug.getmetatable( obj )

	if type( meta ) == "table" and rawget(meta, "__tostring") ~= error then
		success, str = scall( tostring, obj )
	end

	--
	-- If the metamethod succeeds, return it in strong form
	-- Otherwise, return the passed object in string form
	--
	return success and rawstring( str ) or rawstring( obj )

end

return stostring
