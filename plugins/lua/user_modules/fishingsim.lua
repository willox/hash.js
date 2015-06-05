local fish = {
	fish = {
		{name = "trout", weight = 60},
		{name = "marlin", weight = 20},
		{name = "catfish", weight = 20},
	},
	garbage = {
		{name = "can", weight = 30},
		{name = "seaweed", weight = 30},
		{name = "cardboard", weight = 20},
		{name = "net", weight = 19},
		{name = "willox", weight = 1},
	},
	basechance = 40,
	minutes = 0,
	raining = false,
	fishers = {},
}

local function clamp(x, min, max)
	return (x < min and min) or (x > max and max) or x
end

local function fishprint(...)
	print("[FishingSim]", ...)
end

local function isnight()
	local hour = fish.minutes / 60
	return (hour >= 19 or hour < 7)
end

local function chance(ply)
	local ch = fish.basechance
	if isnight() then -- > 2 PM
		ch = ch + (ch * 0.25)
	end
	if fish.raining then
		ch = ch + (ch * 0.25)
	end
	ch = ch + (ply.castdistance - 15) * 0.5
	return math.min(ch, 100)
end

local function sf(a, b) return a.weight < b.weight end
table.sort(fish.fish, sf)
table.sort(fish.garbage, sf)

local function sf(t)
	local percent = math.random(1, 100)
	for _, item in pairs(t) do
		if percent <= item.weight then
			return item
		end
	end
end

local function randomgarbage() return sf(fish.garbage) end
local function randomgarbage() return sf(fish.fish) end

local function catch(ply)
	if not ply.fish then return end
	local type = ply.fish.isgarbage and randomgarbage() or randomfish()
	if ply.fish.isgarbage then
		fishprint(ply.nick .. " caught garbage! Aww... it was a "..type..".")
	else
		fishprint(ply.nick .. " caught a fish! Nice! It was a "..type..".")
	end
	fish.fishers[ply] = nil
end

local function cast(ply, distance)
	distance = tonumber(distance)
	if not distance then fishprint("Invalid cast distance!") return end
	distance = clamp(distance, 15, 30)
	ply.castdistance = distance

	fishprint("Welcome to FishingSim, " .. ply.nick .. "! You cast your line " .. distance .. " units away!")
	fish.fishers[ply] = true
end

local speeddist = {slow = 10, medium = 20, fast = 30}
local speedaggr = {slow = 2, medium = 6, fast = 10}
local function reel(ply, speed)
	if not ply.fish then fishprint(ply.nick .. " doesn't have a fish on the line!") return end
	if ply.fish.isgarbage then catch(ply) return end

	local dist = speeddist[speed]
	if not dist then fishprint("Invalid reel speed!") return end

	ply.fish.dist = ply.fish.dist - dist
	if ply.fish.dist <= 0 then
		catch(ply)
		return
	end

	ply.fish.aggression = ply.fish.aggression + speedaggr[speed]
	if ply.fish.aggression > 25 and math.random(1, 2) == 1 then
		fishprint(ply.nick .. " reeled too quickly! Their fish got away...")
		ply.fish = nil
		return
	end

	fishprint("Keep reeling, "..ply.nick.."!")
end

local function bite(ply, rand)
	ply.fish = {
		distance = (ply.castdistance / 2) + math.random(10, 20),
		aggression = math.random(1, 8),
		isgarbage = rand ~= 1, -- only is fish if == 1
	}
	fishprint(ply.nick .. " has a fish on the line! Reel it in before it gets away (!fish reel <speed (slow, medium, fast)>)!")
	timer.Simple(5, function()
		if ply.fish then
			fishprint(ply.nick .. "'s catch got away! Aww...")
			ply.fish = nil
		end
	end)
end

local last = os.time()
local function think()
	-- handle time
	local t = os.time()
	fish.minutes = fish.minutes + (1 * (t - last)) -- 1 minute passes every second
	fish.minutes = fish.minutes % (24 * 60) -- keep in 24 hour time
	last = t

	-- handle weather
	if math.random(1, 100) == 42 then
		fish.raining = not fish.raining
		fishprint(fish.raining and "It started raining." or "The rain stopped.")
	end

	-- handle catching
	for ply, _ in pairs(fish.fishers) do
		local res = math.random(1, 100 - chance(ply))
		if res <= 20 then
			bite(ply, res)
		end
	end
end
timer.Create("fishing_think", 1, 0, think)

-- display
local width = 16 -- don't change this

local c = {
	space = "  ",

	calm = "-",
	wave = "~",

	cloud = "☁",
	sun = "☀",
	moon = "🌙",

	fish = "🐟",
}

local function sky()
	if fish.raining then
		local ret = c.cloud
		for i = 1, width - 2 do
			ret = ret .. (math.random(1, 3) == 1 and c.space or c.cloud)
		end
		return ret
	else
		local hour = fish.minutes / 60
		local off = isnight() and ((hour >= 19) and hour - 18 or hour + 6) or (hour - 6)
		return string.rep(c.space, off - 1 + (off > 6 and 4 or 0)) .. (isnight() and c.moon or c.sun) .. string.rep(c.space, width - off)
	end
end

local function watersurf()
	local ret = fish.raining and c.wave or c.calm
	for i = 1, width - 1 do
		ret = ret .. ((math.random(1, fish.raining and 2 or 5) == 1) and c.wave or c.calm)
	end
	return ret
end

local function water(ply)
	local ret = ""
	for i = 1, 3 do
		for i = 1, width do
			ret = ret .. ((math.random(1, 10 - (chance(ply) / 10)) == 1) and c.fish or c.space)
		end
		ret = ret .. "\n"
	end
	return string.sub(ret, 1, - 2) -- remove trailing newline
end

local function printscene(ply)
	local msg = "\n"
	msg = msg .. sky()
	msg = msg .. "\n\n\n"
	msg = msg .. watersurf()
	msg = msg .. water(ply)
	print(msg)
end

-- chat commands
local function toplayer(nick, sid)
	local ply = {
		nick = nick,
		sid = sid,
	}
	return ply
end

local function round(x)
	return (x + 0.5) // 1 -- does return a float, but doesn't matter for os.date
end

local function getfishers()
	local ret = ""
	for ply, _ in pairs(fish.fishers) do
		ret = ret .. ply.nick .. ", "
	end
	return string.sub(ret, 1, -3)
end

local commands
commands = {
	help = function(ply)
		fishprint(table.concat(table.GetKeys(commands), ", "))
	end,
	cast = function(ply, args)
		if fish.fishers[ply] then fishprint(ply.nick .. " is already fishing!") return end
		cast(ply, args[1])
	end,
	leave = function(ply)
		if not fish.fishers[ply] then fishprint(ply.nick .. " isn't fishing!") return end
		fish.fishers[ply] = nil
		fishprint("Fish again later, " .. ply.nick .. "!")
	end,
	print = function(ply)
		printscene(ply)
	end,
	status = function(ply)
		fishprint("Weather: "..(fish.raining and "rainy" or "clear"))
		fishprint("Time: "..os.date("%I:%M %p", os.time({year = 2000, month = 1, day = 1, hour = round(fish.minutes / 60), min = round(fish.minutes % 60)})))
		fishprint("Fishers: "..getfishers())
	end,
	reel = function(ply, args)
		reel(ply, string.lower(args[1]))
	end,
}

local chatcmd = "!fish "
hook.Add("Message", "FishingSim", function(nick, sid, msg)
	if not string.find(msg, "^"..chatcmd) then return end

	local input = string.Explode(" ", string.sub(msg, #chatcmd + 1))
	local cmd, args = input[1], {}
	if not (cmd and #cmd > 0 and commands[cmd]) then return end

	for i = 2, #input do
		args[i - 1] = input[i]
	end

	local ply = toplayer(nick, sid)
	commands[cmd](ply, args)
end)
