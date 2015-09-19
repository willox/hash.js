-- currency lib by Zerf, thanks to fixer.io
currency = {}

function currency.Init()
	print("Fetching initial currency information.")
	http.Fetch("http://api.fixer.io/latest?base=USD", function(c, b)
		if c ~= 200 then print("Unable to fetch currency information. Code: " .. c) return end
		local data = json.decode(b)
		data.rates.USD = 1
		currency._rates_usdbase = data.rates
	end)
end

function currency.IsValidCurrency(base)
	return (currency._rates_usdbase[base] ~= nil)
end

function currency.Convert(amt, base, newbase)
	if not (currency.IsValidCurrency(base) and currency.IsValidCurrency(newbase)) then return end

	local amt_in_usd = (currency._rates_usdbase["USD"] / currency._rates_usdbase[base]) * amt
	local amt_in_newbase = amt_in_usd * currency._rates_usdbase[newbase]

	return amt_in_newbase
end

function currency.Query(data, callback)
	local url = "http://api.fixer.io/"
	url = url .. (data.date or "latest")
	url = url .. "?base=" .. (data.base or "USD")
	if data.symbols then url = url .. "&symbols=" .. data.symbols end
	http.Fetch(url, function(c, b)
		if c ~= 200 then print("Unable to fetch currency information. Code: " .. c) return end
		local data = json.decode(b)
		callback(data)
	end)
end

currency.Init()
