local modules = {}

local function require( path )
	if type( path ) ~= "string" then
		error( "bad argument #1 to 'require' (string expected, got " .. type( path ) .. ")", 2 )		
	end

	if not path:match( "^[%w_/]+$" ) then
		error( "bad argument #1 to 'require' (path contains illegal characters)", 2 )
	end

	if modules[ path ] ~= nil then
		return modules[ path ]
	end

	local f, err =  loadfile( "user_modules/" .. path .. ".lua", "t", ENV )
	if err then
		error( err, 2 )
	end

	local ret = { pcall( f ) }

	if not ret[1] then
		error( ret[2], 2 )
	end

	-- Only one returned value is cached
	modules[ path ] = ret[ 2 ]

	return table.unpack( ret, 2 )
end

return require
