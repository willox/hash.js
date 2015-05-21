local serialize		= require "serialize.serialize"
local deserialize	= require "serialize.deserialize"
local types			= require "serialize.types"

local cookies = {}

--
-- Ensure our file exists
--
io.open( "cookies.dat", "a" ):close()

local function Load()

	local fs = io.open( "cookies.dat", "rb" )

	local success, data = pcall( deserialize, fs:read( "a" ) )

	if success then
		cookies = data
	else
		cookies = {}
	end

	fs:close()

end

local function Save()
	
	local data = serialize( cookies )

	os.remove( "cookies.dat" )

	local fs = io.open( "cookies.dat", "wb" )

	fs:write( data )
	fs:close()

end

local function Size()

	local fs = io.open( "cookies.dat", "rb" )

	local size = fs:seek( "end" )

	fs:close()
	
	return size

end

Load()

local meta = {}
meta.__metatable = false
meta.__len = Size

function meta:__index( k )

	if k == "Save" then
		return Save
	end

	return rawget( cookies, k )

end

function meta:__newindex( k, v )

	if k == self or v == self then
		error( "attempt to store cookie table within itself", 2 )
	end

	if k == "Save" then
		error( "attempt to modify protected member 'Save'", 2 )
	end

	if not types[ type( k ) ] and type( k ) ~= "table" then
		error( "attempt to create cookie with invalid key type (" .. type( k ) .. ")", 2 )
	end

	if not types[ type( v ) ] and type( v ) ~= "table" and v ~= nil then
		error( "attempt to create cookie with invalid value type (" .. type( v ) .. ")", 2 )
	end

	if type( k ) == "function" and not pcall( string.dump, k ) then
		error( "attempt to store invalid function as key", 2 )
	end

	if type( v ) == "function" and not pcall( string.dump, v ) then
		error( "attempt to store invalid function as value", 2 )
	end

	cookies[ k ] = v

end

function meta:__pairs()

	local t = {}

	for k, v in pairs( cookies ) do
		t[ k ] = v
	end

	return pairs( t )

end

return setmetatable( {}, meta )

