local function seedrandom()
	math.randomseed(os.time())
	math.randomseed(os.time() + math.random())
	math.random() math.random() math.random() math.random()
end

local function urlencode(str)
	return (string.gsub(str, "([^%w%-%_%.%~])", function(c)
		return string.format("%%%02X", string.byte(c))
	end))
end

local function randomchars(len) -- credit to swad I guess
	seedrandom()
	local out = ""
	for i = 1, len or 11 do
		local r = math.random(1, 3)
		if r == 1 then
			out = out .. string.char(math.random(97, 122))
		elseif r == 2 then
			out = out .. string.char(math.random(65, 90))
		else
			out = out .. string.char(math.random(48, 57))
		end
	end
	return out
end

local apikey = "AIzaSyBdNHtSytlHao_L5l_dPe-FByVapmKzd0U" -- idgaf; registered as GLua Chat YouTube or something

yt = {}

local vidbase = "http://youtube.com/watch?v="

local function GetVideo(str, method, shouldretry, tries)
	math.randomseed(os.time() + math.random())
	method = method or "keyword"
	shouldretry = shouldretry or true
	tries = tries or 0
	local qstr
	if method == "keyword" then
		if not str then error("No keyword given. For a truly random video, use yt.RandomVideoChars or yt.RandomVideoWord.") return end
		qstr = str
	elseif method == "chars" then
		seedrandom()
		qstr = randomchars(math.random(3, 24))
	elseif method == "word" then
		http.Fetch("http://randomword.setgetgo.com/get.php", function(c, b)
			if c ~= 200 then print("HTTP Error: " .. c) return end
			GetVideo(string.gsub(b, "[\r\n]", ""), "word_got")
		end)
		return
	elseif method == "word_got" then
		qstr = str
	end
	local url = "https://www.googleapis.com/youtube/v3/search?key=" .. apikey .. "&part=snippet&type=video&maxResults=50&q=" .. urlencode(qstr)
	http.Fetch(url, function(c, b)
		if (c ~= "200" and c ~= 200) then print("HTTP Error: " .. c) return end
		local data = json.decode(b)
		if not (data.items and #data.items > 0) then
			if tries == 0 then
				print("Result error or no items", shouldretry and "retrying until we find one..." or nil)
			elseif tries == 30 then
				print("Gave up after 30 tries.")
				return
			end
			if shouldretry then
				timer.Simple(0, function() GetVideo(str, (method == "word_got") and "word" or method, shouldretry, tries + 1) end)
			end
			return
		end
		local vid = data.items[math.random(1, #data.items)]
		print(vidbase .. vid.id.videoId .. " (str=" .. qstr .. ", tries=" .. tries .. ")\n" .. vid.snippet.title)
	end)
end

function yt.RandomVideo(str)
	GetVideo(str)
end

function yt.RandomVideoChars()
	GetVideo(nil, "chars")
end

function yt.RandomVideoWord()
	GetVideo(nil, "word")
end
