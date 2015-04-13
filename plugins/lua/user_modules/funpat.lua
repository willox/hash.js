local patterns = {
	{"[AEIOUaeiou]", "e"},
}

local function ShouldReply(msg)
	if #msg > 200 and math.random() > 0.10 then return true end

	return math.random() > 0.97
end

hook.Add("Message", "dankreplace", function(name, CID, message) 
	if ShouldReply(message) then
		local pattern = patterns[math.random(1, #patterns)]
		local newMessage = string.gsub (message, pattern[1], pattern[2])
		print (name .. ": " .. newMessage)
	end
end)