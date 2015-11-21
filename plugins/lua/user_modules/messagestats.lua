cookie.texts = cookie.texts or {};

cookie.texts.mean = cookie.texts.mean or 0;
cookie.texts.tracked = cookie.texts.tracked or 0;
cookie.texts.totallen = cookie.texts.totallen or 0;
cookie.texts.ids = cookie.texts.ids or {};
cookie.texts.cocks = cookie.texts.cocks or 0

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
	
	cookie.texts.ids[stmd].len = (cookie.texts.ids[stmd].len or 0) + len / (total + len);
	
	cookie.texts.totallen = cookie.texts.totallen + len;
end

hook.Add("Message", "Lengthometer", function(name,id, text) 
	add(id, text:len());
		
	text:gsub("cock", function()
		cookie.texts.cocks = cookie.texts.cocks + 1	
	end )
end)

stats = stats or {};

function stats.MeanLength() return cookie.texts.mean end

function stats.TotalCharsSent(id)
	if(id) then
		local info = cookie.texts.ids[tostring(id)];
		if(not info) then return; end
		return info.len * cookie.texts.totallen;
	end
	return cookie.texts.totallen;
end
