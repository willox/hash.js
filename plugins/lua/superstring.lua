local meta = getmetatable ""
meta.__metatable = false

function meta:__call( )

	local f, err = load( self, "string", "t", ENV )

	if err then
		error( err, 2 )
	end

	return f()

end

function meta:__index(k)
	
	if type( k ) == "number" then
		return self:sub( k, k )
	end
	
	return string[k]
	
end

function meta:__mod( arg )

	if ( type( arg ) == "string" ) then

		return string.format( self, arg )

	else

		return string.format( self, unpack( arg ) )

	end

end
