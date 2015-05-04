function table.Random(tbl)
    local i = 1
    local rk = math.random(1, #tbl)
    for k,v in pairs(tbl) do
        if i == rk then return v, k end
        i = i + 1
    end
end
