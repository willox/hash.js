local cookies = {}

local function encode( str )

	str = string.format( "%q", str )
	str = string.gsub( str, "\\\n", "\\n" )

	return str

end

local function decode( str )

	local f = load( "return " .. str, "decode", "t", {} )

	return f()

end

-- Ensure our file exists
io.open( "cookies.dat", "a" ):close()

local function Load()

	for line in io.lines( "cookies.dat" ) do

		local k, v = string.unpack( "zz", line )

		cookies[ decode( k ) ] = decode( v )

	end

end

local function Save()

	os.remove( "cookies.dat" )

	local fs = io.open( "cookies.dat", "w" )

	for k, v in pairs( cookies ) do

		fs:write( string.pack( "zz", encode( k ), encode( v ) ) )
		fs:write( "\n" )

	end

	fs:close()

end

Load()

local meta = {}
meta.__index = cookies
meta.__metatable = false

function meta:__newindex( k, v )

	k = tostring( k )

	if v ~= nil then

		v = tostring( v )
		
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