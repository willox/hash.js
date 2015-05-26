local meta = getmetatable ""
meta.__metatable = false

function meta:__call( ... )

	local f, err = load( self, "string", "t", ENV )

	if err then
		error( err, 2 )
	end

	return f( ... )

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

		return string.format( self, table.unpack( arg ) )

	end

end

local function eval_expr( expr )
	local try_ret, err = load("return " .. expr, "interp", "t", _ENV)
	if not err then return tostring(try_ret()) end
	
	return "{err: " .. err .. "}"
end
function meta:__bnot( arg )
	return string.gsub(arg, "$([^%s]+)", function(var) return eval_expr(var) end)
end
