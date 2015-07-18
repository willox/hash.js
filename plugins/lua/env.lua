--
-- Returns a copy of a table with all current members read-only
-- If target is defined, the returned result will be equal to target
--
local function ProtectTable( tab, target, fakefunction )

	fakefunction = fakefunction or {}

	local index = {}
	local ret = target or {}

	--
	-- Copy new variables in to our table
	-- Metatable-less subtables are also protected
	--
	for k, v in pairs( tab ) do

		if v == target then

			index[ k ] = ret

		elseif getmetatable( v ) == nil and type( v ) == "table" then

			index[ k ] = ProtectTable( tab[ k ] )

		else

			index[ k ] = tab[ k ]

		end

	end

	local meta			= {}
	meta.__metatable	= false
	function meta:__index( k )

		if ( fakefunction[ k ] ) then
			return rawget( index, k )(self)
		end

		return rawget( index, k )

	end

	function meta:__newindex( k, v )

		if rawget( index, k, v ) then

			error( "attempt to modify read-only member '" .. k .. "'", 2 )

			return

		end

		rawset( self, k, v )

	end

	function meta:__pairs()

		local t = {}

		for k, v in next, self, nil do
			t[ k ] = v
		end

		for k, v in pairs( index ) do
			t[ k ] = self[ k ] -- you have to reindex it since of metatable indexing
		end

		return next, t, nil

	end

	return setmetatable( ret, meta )

end

cookie = require "./sand_modules/cookie"

local last_steamid
function SetLastExecutedSteamID( steamid )

	last_steamid = steamid

end

function GetLastExecutedSteamID()

	return last_steamid

end

local INDEX = {
	_G					= ENV,
	_VERSION			= _VERSION,

	--
	-- 'Safe' default methods and libraries
	--
	assert				= assert,
	error				= error,
	getmetatable		= getmetatable,
	ipairs				= ipairs,
	next				= next,
	pairs				= pairs,
	print				= print,
	rawequal			= rawequal,
	select				= select,
	setmetatable		= setmetatable,
	tonumber			= tonumber,
	tostring			= tostring,
	type				= type,

	math				= math,
	string				= string,
	table				= table,
	utf8				= utf8,

	--
	-- 3rd party libraries
	--
	cookie				= cookie,
	hook				= require "./sand_modules/hook",
	include				= require "./sand_modules/include",
	require				= require "./sand_modules/require",
	timer				= require "./sand_modules/timer",
	SteamID             = function(self) return last_steamid end,

	--
	-- Modified default libraries
	--
	io					= require "./sand_modules/io",
	os					= require "./sand_modules/os",
}

function INDEX.load( chunk, chunkname, _, fenv )

	if fenv == nil then

		fenv = ENV

	end

	return load( chunk, chunkname, "t", fenv )

end

return ProtectTable( INDEX, ENV, {
	SteamID = true -- SteamID is a function but needs to remain backwards compat
})
