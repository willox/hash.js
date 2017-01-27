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

local function getvarvalue (name)
	local value, found
	
	-- try local variables
	local i = 1
	while true do
		local n, v = debug.getlocal(5, i)
		if not n then break end
		if n == name then
		  value = v
		  found = true
		end
		i = i + 1
	end
	if found then return value end
	
	-- try upvalues
	local func = debug.getinfo(5).func
	i = 1
	while true do
		local n, v = debug.getupvalue(func, i)
		if not n then break end
		if n == name then return v end
		i = i + 1
	end
end

local function eval_expr( expr )
	local varval = getvarvalue(expr)
	if varval then return tostring(varval) end
	
	local try_ret, err = load("return " .. expr, "interp", "t", _ENV)
	if not err then return tostring(try_ret()) end
	
	return "{err: " .. err .. "}"
end

function meta:__bnot( arg )
	local str,_ = string.gsub(arg, "%$([^\'\"%[%]%s]+)", function(var) return eval_expr(var) end)
	return str
end
