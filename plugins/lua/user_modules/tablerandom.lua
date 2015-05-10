function table.Random(tbl)
    local count = 0
    for _,_ in pairs(tbl) do count = count + 1 end
    local i = 1
    local rk = math.random(1, count)
    for k,v in pairs(tbl) do
        if i == rk then return v, k end
        i = i + 1
    end
end
