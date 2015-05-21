local vectormeta = {}
function vectormeta:__index(key)
  if key == "x" or key == "y" or key == "z" then return self.comps[key] end
  local comps = {}
  local nonSwizzled = string.gsub(key, "[xyz]", function(comp)
    table.insert(comps, self.comps[comp])
    return ""
  end)
  
  -- If we swizzled the whole input and there's at least one swizzled comp, we're gucci
  if #nonSwizzled == 0 and #comps > 0 then
    return Vector(table.unpack(comps))
  end
  
  return vectormeta[key]
end

function vectormeta:__tostring()
  return string.format("[%f %f %f]", self.x, self.y, self.z)
end

function vectormeta:__add(b)
  if getmetatable(b) == vectormeta then
    return Vector(self.x+b.x, self.y+b.y, self.z+b.z)
  end
  error("Trying to add '" .. type(b) .. "' to a Vector")
end
function vectormeta:__sub(b)
  if getmetatable(b) == vectormeta then
    return Vector(self.x-b.x, self.y-b.y, self.z-b.z)
  end
  error("Trying to subtract '" .. type(b) .. "' from a Vector")
end
function vectormeta:__unm()
  return self * -1
end
function vectormeta:__mul(b)
  if getmetatable(b) == vectormeta then
    return self:Dot(b)
  elseif type(b) == "number" then
    return Vector(self.x*b, self.y*b, self.z*b)
  end
  error("Trying to mul '" .. type(b) .. "'  by a Vector")
end
function vectormeta:__len()
  return self:Length()
end
function vectormeta:__eq(b)
  return self.x == b.x and self.y == b.y and self.z == b.z
end

function vectormeta:Normalized()
  local l = self:Length()
  return Vector(self.x/l, self.y/l, self.z/l)
end
vectormeta.Normalize = vectormeta.Normalized -- Garry shit

function vectormeta:Dot(b)
  return self.x*b.x + self.y*b.y + self.z*b.z
end
vectormeta.DotProduct = vectormeta.Dot -- Garry shit
function vectormeta:Cross(b)
  return Vector(self.y*b.z - self.z*b.y, self.z*b.x - self.x*b.z, self.x*b.y - self.y*b.x)
end

function vectormeta:LengthSq()
  return self.x^2 + self.y^2 + self.z^2
end
function vectormeta:Length()
  return math.sqrt(self:LengthSq())
end

function vectormeta:Distance(b)
  return (b-self):Length()
end

function Vector(x, y, z)
  if getmetatable(x) == vectormeta then
    x, y, z = x.x, x.y, x.z
  end
  x = x or 0
  
  -- Prevent (x, y) vector turning into (x, y, x)
  if x and not y and not z then
    y = x
    z = x
  else
    y = y or 0
    z = z or 0
  end
  
  return setmetatable({comps = {x=x, y=y, z=z}}, vectormeta)
end

if true then return end

assert(Vector() == Vector(0, 0, 0))
assert(Vector(0) == Vector(0, 0, 0))
assert(Vector(1) == Vector(1, 1, 1))

assert(Vector(1, 2) == Vector(1, 2, 0))

assert(Vector(3, 1, 2).yzx == Vector(1, 2, 3))

assert(-Vector(2, 5, 10) == Vector(-2, -5, -10))

assert(Vector(1, 2, 3):Normalized() * Vector(-1, -2, -3):Normalized() == -1)

assert(Vector(0, 1, 0):Cross(Vector(-1, 0, 0)) == Vector(0, 0, 1))
