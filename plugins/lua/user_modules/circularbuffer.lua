local self = {}

local CircularBuffer = function (size)
	local o = {}
	o.array     = {}
	o.count     = 0
	o.size      = size
	o.nextIndex = 1
	
	setmetatable (o, { __index = self })
	return o
end

function self:add (v)
	self.array [self.nextIndex] = v
	self.count     = math.min (self.size, self.count + 1)
	self.nextIndex = (self.nextIndex % self.size) + 1
end

function self:clear ()
	self.array     = {}
	self.count     = 0
	self.nextIndex = 1
end

function self:get (n)
	if n < 0 then
		n = -n
		return self.array [(self.nextIndex - n - 1) % self.size + 1]
	else
		return self.array [(self.nextIndex + n - 2) % self.size + 1]
	end
end

function self:getCount ()
	return self.count
end

function self:getSize ()
	return self.size
end

return CircularBuffer