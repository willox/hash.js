local serialize		= require "serialize.serialize"
local deserialize	= require "serialize.deserialize"
local types			= require "serialize.types"

local cookies = {}
local cookie_members = {}

-- this is persistance for lua modules' protection

local persist = true

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
	cookies._protected_modules = cookies._protected_modules or {}

	fs:close()

end

function cookie_members.Save()

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

function cookie_members.StopPersist()

	persist = false;

end

local module_cookies = {};

function cookie_members.GetProtected( identifier )

	if ( IsSandboxed() and not IsInternal() ) then -- confirm a user input this

		local ret = cookies._protected_user[ GetLastExecutedSteamID() ]

		if (not ret) then
			ret = {}
			cookies._protected_user[ GetLastExecutedSteamID() ] = ret
		end

		return ret

	elseif ( persist and not module_cookies[ identifier ] ) then

		local ret = cookies._protected_modules[ identifier ]

		if ( not ret ) then
			ret = {}
			cookies._protected_modules[ identifier ] = ret
		end

		module_cookies[ identifier ] = true

		return ret

	end

	error( "attempt to get protected cookies from non user script code", 2 )

end

function cookie_members.ResetProtected()

	if ( IsSandboxed() and not IsInternal() ) then -- confirm a user input this

		cookies._protected_user[ GetLastExecutedSteamID() ] = nil

	end

end

Load()

local meta = {}
meta.__metatable = false
meta.__len = Size

function meta:__index( k )

	if ( cookie_members[ k ] ) then
		return cookie_members[ k ]
	end

	if ( k == "_protected_user" or k == "_protected_modules" ) then
		return nil
	end

	return rawget( cookies, k )

end

function meta:__newindex( k, v )

	if ( cookie_members[ k ] or k == "_protected_user" or k == "_protected_modules" ) then
		error( "attempt to modify protected member '" .. k .. "'", 2 )
	end

	cookies[ k ] = v

end

function meta:__pairs()

	local t = {}

	for k, v in pairs( cookies ) do
		if ( k ~= "_protected_user" and k ~= "_protected_modules" ) then
			t[ k ] = v
		end
	end

	return pairs( t )

end

return setmetatable( {}, meta )
