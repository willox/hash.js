local cookies = {}

-- Ensure our file exists
io.open( "cookies.dat", "a" ):close()

local function Load()

	for line in io.lines( "cookies.dat" ) do

		local k, v = string.unpack( "zz", line )

		cookies[ k ] = v

	end

end

local function Save()

	os.remove( "cookies.dat" )

	local fs = io.open( "cookies.dat", "w" )

	for k, v in pairs( cookies ) do

		fs:write( string.pack( "zz", k, v ) )
		fs:write( "\n" )

	end

	fs:close()

end

Load()

local meta = {}
meta.__index = cookies
meta.__metatable = FAKE_META

function meta:__newindex( k, v )

	k = tostring( k )
	k = k:gsub( "\n", "" )
	k = k:gsub( "\0", "" )

	if v ~= nil then

		v = tostring( v )
		v = v:gsub( "\n", "" )
		v = v:gsub( "\0", "" )

	end

	cookies[ k ] = v

	Save()

end

function meta:__pairs()

	local t = {}

	for k, v in pairs( cookies ) do
		t[ k ] = v
	end

	return pairs( t )

end

return setmetatable( {}, meta )