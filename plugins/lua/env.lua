local ENV = {}

--
-- Returns a copy of a table with all current members read-only
-- If target is defined, the returned result will be equal to target
--
local function ProtectTable( tab, target )

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
	meta.__index		= index
	meta.__metatable	= false

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

		for k, v in pairs( meta.__index ) do
			t[ k ] = v
		end

		return next, t, nil

	end

	return setmetatable( ret, meta )

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
	pcall				= pcall,
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
	cookie				= require "./sand_modules/cookie",
	hook				= require "./sand_modules/hook",
	include				= require "./sand_modules/include",
	require				= require "./sand_modules/require",
	timer				= require "./sand_modules/timer",

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

return ProtectTable( INDEX, ENV )
