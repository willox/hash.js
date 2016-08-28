local api_keys = {
	"AIzaSyA8OmKcw2DMNkJicyCJ0vqvf90xgeH52zE",
	"AIzaSyBdNHtSytlHao_L5l_dPe-FByVapmKzd0U",
	"AIzaSyD74kTqDqj6YQQdKYH9n5-6kG-l_oX_41A" -- thanks playx
}

local function round(x) return math.floor(x + 0.5) end

local pattern_youtube = "youtube%.com/watch%?v=([%w%-_]+)"
local pattern_youtu_be = "youtu%.be/([%w%-_]+)"

local current_chat_message

local function debuglog(error_message)
	if string.sub(current_chat_message, 1, 1) == "]" then
		print("Error: " .. tostring(error_message))
	end
end

local function FetchVideoInfo(video_id, callback, _keynum)
	_keynum = _keynum or 1

	local apikey = api_keys[_keynum]
	if not apikey then debuglog("usage limits exceeded") return end

	local url = string.format("https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics&prettyPrint=false&maxResults=1&key=%s&id=%s", apikey, video_id)

	http.Fetch(url, function(_, body)
		local data = json.decode(body)

		if data.error then
			if data.error.errors[1].reason == "dailyLimitExceeded" then
				debuglog("key " .. tostring(_keynum) .. " has exceeded limits")
				FetchVideoInfo(video_id, callback, _keynum + 1)
			else
				debuglog(data.error.message)
			end

			return
		end

		if not (data.items and data.items[1] and data.items[1].snippet and data.items[1].statistics) then debuglog("missing JSON fields") return end

		callback({
			likes = tonumber(data.items[1].statistics.likeCount),
			dislikes = tonumber(data.items[1].statistics.dislikeCount),
			title = data.items[1].snippet.title
		})
	end)
end

hook.Add("Message", "youtube video info", function(_, _, msg)
	local video_id = string.match(msg, pattern_youtube) or string.match(msg, pattern_youtu_be)

	if not video_id then current_chat_message = nil return end

	current_chat_message = msg

	FetchVideoInfo(video_id, function(info)
		local likes = info.likes or 0
		local dislikes = info.dislikes or 0

		local star_count = round(5 * (likes / (likes + dislikes)))

		if star_count == math.huge then star_count = 0 end

		local star_string = string.rep("★", star_count) .. string.rep("✩", 5 - star_count)

		print(string.format("YouTube: %s [%s]", info.title or "[No name]", star_string))
	end)
end)
