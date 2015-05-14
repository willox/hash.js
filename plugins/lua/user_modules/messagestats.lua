cookie.texts = cookie.texts or {
	mean = 0;
	tracked = 0;
};

local function add(len)
	local mean = cookie.texts.mean;
	local amt = cookie.texts.tracked;
	
	mean = (mean * (amt / (amt + 1))) + len / (amt + 1);
	amt = amt + 1;
	
	cookie.texts.tracked = amt;
	cookie.texts.mean = mean;
end

hook.Add("Message", "Lengthometer", function(name,id, text) 
	add(text:len());
end)

stats = stats or {};

function stats.MeanLength()
	local max = 0;
	for i = 1, #cookie.texts do 
		max = max + cookie.texts[i];
	end
	return max / #cookie.texts;
end