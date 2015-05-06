local function include( path )
	if type( path ) ~= "string" then
		error( "bad argument #1 to 'include' (string expected, got " .. type( path ) .. ")", 2 )		
	end

	if not path:match( "^[%w/]+$" ) then
		error( "bad argument #1 to 'include' (path contains illegal characters)", 2 )
	end

	local f, err =  loadfile( "user_modules/" .. path .. ".lua", "t", ENV )
	if err then
		error( err, 2 )
	end

	local ret = { pcall( f ) }

	if not ret[1] then
		error( ret[2], 2 )
	end

	return table.unpack( ret, 2 )
end

return include
