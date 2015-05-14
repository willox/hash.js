cookie.texts = cookie.texts or {
	mean = 0;
	tracked = 0;
};

cookie.texts.totallen = cookie.texts.totallen or 0;
cookie.texts.ids = cookie.texts.ids or {};

local function add(stmd, len)
	local mean = cookie.texts.mean;
	local amt = cookie.texts.tracked;
	
	mean = (mean * (amt / (amt + 1))) + len / (amt + 1);
	amt = amt + 1;
	
	cookie.texts.tracked = amt;
	cookie.texts.mean = mean;
	
	
	local total = cookie.texts.totallen;
	
	for k,v in pairs(cookie.texts.ids) do
		v.len = v.len * (total / (total + len));
	end
	cookie.texts.ids[stmd] = cookie.texts.ids[stmd] or {};
	
	local steamlen = cookie.texts.ids[stmd].len;
	
	cookie.texts.ids[stmd].len = (steamlen or 0) * (total / (total + len)) + len / (total + len);
	
	cookie.texts.totallen = cookie.texts.totallen + len;
end

hook.Add("Message", "Lengthometer", function(name,id, text) 
	add(id, text:len());
end)

stats = stats or {};

function stats.MeanLength()
	local max = 0;
	for i = 1, #cookie.texts do 
		max = max + cookie.texts[i];
	end
	return max / #cookie.texts;
end

function stats.TotalCharsSent(id)
	if(id) then
		local info = cookie.texts.ids[id];
		if(not info) then return; end
		return info.len * cookie.texts.totallen
	end
	return cookie.texts.totallen;
end