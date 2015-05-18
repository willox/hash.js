f = f or {}

f.toFunction = function (func)
	if type (func) == "function" then
		return func
	elseif type (func) == "table" then
		return function (x)
			return func [x]
		end
	elseif type (func) == "string" then
		return f [func]
	end
end

f.toString = function (v)
	local type = type (v)
	
	if type == "string" then
		return string.format ("%q", v)
	elseif type == "table" then
		if getmetatable (v) == f.mt.list then
			return tostring (v)
		end
		
		return "{ " .. tostring (v) .. " }"
	end
	
	-- Default to tostring
	return tostring (v)
end

f.apply  = function (f, x) return function (...) return f (x, ...) end end
f.call   = function (f, ...) return f (...) end
f.concat = table.concat

f.index = function (t, k)
	if t [k] then
		return t [k]
	elseif type (k) == "number" then
		return t [k]
	elseif type (k) == "table" then
		return f.list (k):map (t)
	end
end

f.newindex = function (t, k, v)
	if type (k) == "number" then
		t [k] = v
	elseif type (k) == "table" then
		if type (v) == "table" then
			for i = 1, #k do
				t [k [i]] = v [i]
			end
		else
			for i = 1, #k do
				t [k [i]] = v
			end
		end
	end
end

f.eq  = function (x, y) return x == y end
f.neq = function (x, y) return x ~= y end
f.neg = function (x) return -x end

f.add = function (x, y) return x + y end
f.mul = function (x, y) return x * y end
f.sub = function (x, y) return x - y end
f.div = function (x, y) return x / y end
f.mod = function (x, y) return x % y end
f.pow = function (x, y) return x ^ y end
