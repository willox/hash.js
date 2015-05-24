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

	cookies._protected_user = cookies._protected_user or {}

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

local function GetProtected()

	if ( IsSandboxed() and not IsInternal() ) then -- confirm a user input this

		local ret = cookies._protected_user[ GetLastExecutedSteamID() ]

		if (not ret) then
			ret = {}
			cookies._protected_user[ GetLastExecutedSteamID() ] = ret
		end

		return ret

	end

	error( "attempt to get protected cookies from non user script code", 2 )

end

local function ResetProtected()

	if ( IsSandboxed() and not IsInternal() ) then -- confirm a user input this

		cookies._protected_user[ GetLastExecutedSteamID() ] = nil

	end

end

Load()

local meta = {}
meta.__metatable = false
meta.__len = Size

function meta:__index( k )

	if k == "Save" then
		return Save
	end

	if ( k == "GetProtected" ) then
		return GetProtected
	end

	if ( k == "ResetProtected" ) then
		return ResetProtected
	end

	if ( k == "_protected_user" ) then
		return nil
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

	if ( k == "_protected_user" ) then
		error( "attempt to modify protected member '_protected_user'", 2 )
	end

	if ( k == "GetProtected" ) then
		error( "attempt to modify protected member 'GetProtected'", 2 )
	end

	if ( k == "ResetProtected" ) then
		error( "attempt to modify protected member 'ResetProtected'", 2 )
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
		if ( k ~= "_protected_user" ) then
			t[ k ] = v
		end
	end

	return pairs( t )

end

return setmetatable( {}, meta )
