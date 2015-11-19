--Define required functions
local function levenshtein(a,b)local c=string.len(a)local d=string.len(b)local e={}local f=0;if c==0 then return d elseif d==0 then return c elseif a==b then return 0 end;for g=0,c,1 do e[g]={}e[g][0]=g end;for h=0,d,1 do e[0][h]=h end;for g=1,c,1 do for h=1,d,1 do if a:byte(g)==b:byte(h)then f=0 else f=1 end;e[g][h]=math.min(e[g-1][h]+1,e[g][h-1]+1,e[g-1][h-1]+f)end end;return e[c][d]end
local function split(a,b)local c={}local d="(.-)"..b;local e=1;local f,g,h=a:find(d,1)while f do if f~=1 or h~=""then table.insert(c,h)end;e=g+1;f,g,h=a:find(d,e)end;if e<=#a then h=a:sub(e)table.insert(c,h)end;return c end

--Define default image replies
local imagereplies = {
    truestory = "https://i.imgur.com/QanrHU2.png",
    iunderstoodthatreference = "http://i.imgur.com/jrhY2IW.gif",
    gotthatreference = "http://i.imgur.com/jrhY2IW.gif",
    captainamerica = "http://i.imgur.com/jrhY2IW.gif",
    referenceunderstood = "http://i.imgur.com/jrhY2IW.gif",
    aliens = "https://i.imgur.com/yEbscSL.png",
    neat = "http://i.imgur.com/wyhhIYY.gif",
    themoreyouknow = "http://i.imgur.com/awczpCj.gif",
    tmyk = "http://i.imgur.com/awczpCj.gif",
    thatsracist = "http://i.imgur.com/awczpCj.gif",
    datsracist = "http://i.imgur.com/awczpCj.gif",
    mybodyisready = "http://i.imgur.com/lMUBzJo.gif",
    hugemistake = "http://i.imgur.com/thJwJbO.gif",
    reversethatsapenis = "http://i.imgur.com/thJwJbO.gif",
    myfetish = "http://gfycat.com/OrnateFlawedAfricanclawedfrog",
    idontbelieveyou = "http://gfycat.com/SpitefulImmediateGannet",
    disgonbgud = "http://gfycat.com/ImmenseRectangularCero",
    thisgonnabegood = "http://gfycat.com/ImmenseRectangularCero",
    deaddove = "https://i.imgur.com/NQookyt.png",
    idontknowwhatiexpected = "https://i.imgur.com/NQookyt.png",
    slowclap = "http://i.imgur.com/6wYnlyj.gif",
    thatescalatedquickly = "http://gfycat.com/AdolescentUniformKillifish",
    takemymoney = "https://i.imgur.com/blqUQAO.jpg",
    notbad = "https://i.imgur.com/4vXRGQJ.png",
    abandonthread = "http://gfycat.com/WateryNeglectedCavy",
    myfeels = {
        "http://i.imgur.com/oLyMS8K.gif",
        "http://i.imgur.com/FT2VXxo.gif",
        "http://i.imgur.com/LwaOWLk.gif"
    },
    thefeels = {
        "http://i.imgur.com/oLyMS8K.gif",
        "http://i.imgur.com/FT2VXxo.gif",
        "http://i.imgur.com/LwaOWLk.gif"
    },
    godno = "http://gfycat.com/SerpentineHeartfeltLarva",
    dontgiveashit = "http://gfycat.com/HandmadeNegligibleAfricanfisheagle",
    saddoctor = "http://gfycat.com/LeafyConcernedDassierat",
    colbertpopcorn = "http://gfycat.com/MeekPeskyCockroach",
    costanza = "https://i.imgur.com/G2uNWMn.jpg",
    thanksobama = {
        "https://i.imgur.com/L2QPeS1.jpg",
        "https://i.imgur.com/qKOhObk.jpg",
        "http://gfycat.com/ThoroughIdioticKissingbug"
    },
    foreveralone = "https://i.imgur.com/1O2kNX3.png",
    speechless = "http://i.imgur.com/JKsDCgV.gif",
    ohgodwhy = "https://i.imgur.com/6RRBfCp.jpg",
    lowqualitybait = "https://i.imgur.com/6tSSlgU.jpg",
    dealwithit = {
        "http://i.imgur.com/LDbhQH4.gif",
        "http://i.imgur.com/fQFswMx.gif",
        "http://i.imgur.com/RgLuCO6.gif",
        "http://i.imgur.com/yQRuf1z.gif",
        "http://i.imgur.com/QXdqtkP.gif"
    },
    sadkeanu = "https://i.imgur.com/L3RW1CF.jpg",
    youtried = "http://i.imgur.com/eAhcSTr.gif",
    thatsapenis = "http://gfycat.com/ExcitableAcrobaticCrane",
    whynotboth = "http://gfycat.com/DapperDelayedGerbil",
    artplease = "https://i.imgur.com/ihhjxYs.jpg",
    trollface = "https://i.imgur.com/GspFFKf.jpg",
    notthebees = "http://i.imgur.com/FpwQnlH.gif",
    feelsbad = "https://i.imgur.com/Xo9GNok.jpg",
    ifyouknowwhatimean = "https://i.imgur.com/y0OuuYc.png",
    dozensofus = "http://i.imgur.com/MNWxr0Q.gif",
    okay = "https://i.imgur.com/42G7fd8.png",
    youdarealmvp = "https://i.imgur.com/dRHBecg.jpg",
    notsureifserious = "https://i.imgur.com/4y9m2M0.jpg",
    whatamidoing = {
        "https://i.imgur.com/yOAbwY3.jpg",
        "https://i.imgur.com/fHRVPXy.jpg",
        "https://i.imgur.com/mY39C4a.png"
    },
    whoosh = "http://gfycat.com/FirstScentedAstrangiacoral",
    whatyearisit = "https://i.imgur.com/omBCzFn.jpg",
    ohyou = "https://i.imgur.com/DxIhWpb.png",
    michaeljacksonpopcorn = "http://gfycat.com/ElasticRadiantAmericanindianhorse",
    mjpopcorn = "http://gfycat.com/ElasticRadiantAmericanindianhorse",
    iknowsomeofthesewords = "http://gfycat.com/UnitedImpureAlaskajingle",
    nope = "http://gfycat.com/MellowConsciousAsianwaterbuffalo",
    ["2spooky4me"] = "http://i.imgur.com/rXE8P9O.gifv",
    ["2spooky"] = "http://i.imgur.com/rXE8P9O.gifv",
    mindblown = "http://i.imgur.com/rzKwVq8.gif",
    badjokecena = "https://i.imgur.com/LjLeJM6.png",
    itshappening = "http://i.imgur.com/Hf1yqgr.gif",
    facepalm = "https://i.imgur.com/FwsRdVg.jpg",
    slowpoke = "https://i.imgur.com/UlsmWsD.png",
    thatsthejoke = "http://gfycat.com/GlassAmusingBeardedcollie",
    sensiblechuckle = "http://i.imgur.com/UCuu9kw.gifv",
    yeahrightsure = "https://i.imgur.com/gQ0UjTV.jpg",
    yeahsure = "https://i.imgur.com/gQ0UjTV.jpg",
    sickreferencebro = "http://gfycat.com/AdeptSatisfiedDegu",
    sickrefrence = "http://gfycat.com/AdeptSatisfiedDegu",
    youdontsay = "https://i.imgur.com/uJtBTE6.png",
    heavybreathing = "https://i.imgur.com/P9TAu3k.jpg",
    areyouawizard = "https://i.imgur.com/C8d6rkP.jpg",
    rekt = "https://i.imgur.com/7R7SRof.jpg",
    feelsgoodman = {
        "https://i.imgur.com/GZf4Mv3.jpg",
        "https://i.imgur.com/GZf4Mv3.jpg"
    },
    iseewhatyoudidthere = "https://i.imgur.com/dpG2Swr.jpg",
    nowkiss = "https://i.imgur.com/kmjXwTF.png",
    popcorn = "http://gfycat.com/PaleScentedImpala",
    motherofgod = "https://i.imgur.com/6iJslps.png",
    conspiracykeanu = "https://i.imgur.com/3DX9lR5.jpg",
}

--Define default image endings
local endings = {
    "gif",
    "gifv",
    "png",
    "jpg",
    "swf",
    "exe"
}

--Ensure the cookies to store image endings are present.
cookie.maymays = cookie.maymays or {}
cookie.maymays.imagereplies = cookie.maymays.imagereplies or {}
cookie.maymays.imageendings = cookie.maymays.imageendings or {}

--This is done so that default image endings/replies aren't deleted, whilst user-added image endings/replies are still used.
for k,v in pairs(imagereplies) do
    cookie.maymays.imagereplies[k] = v
end

for k,v in pairs(endings) do
    cookie.maymays.imageendings[k] = v
end

--I don't know what this is for (really)
local function scanMemes(_,__,msg)
    local explode = split(msg, " ")

    for _,word in ipairs(explode) do
        local meme,ending = word:match("^(.+)%.(.-)$")

        if meme and ending then
            local proceed = false
            for _,v in ipairs(cookie.maymays.imageendings) do
                if(levenshtein(ending,v) < 2) then
                    proceed = true
                    break
                end
            end

            if proceed then
                for name,link in pairs(cookie.maymays.imagereplies) do
                    if(levenshtein(name,meme) < 2) then
                        if(type(link) == "table") then
                            print(link[math.random(1,#link)])
                        else
                            print(link)
                        end
                    end
                end
            end
        end
    end
end

--Same here. What does this do? (no really.)
hook.Add("Message","ImageLinker",scanMemes)
