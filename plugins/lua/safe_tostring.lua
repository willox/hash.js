function safe_tostring( obj )

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

return safe_tostring