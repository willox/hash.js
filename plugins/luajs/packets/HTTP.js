"use strict";
const blacklist = config.HTTPBlacklist;
const url       = require("url");
const dns       = require("dns");
const request   = require("request");


const HTTP = class HTTP
{

    get regex()
    {
        return /^([^]+?);([^]+?);([^]+)$/;
    }

    constructor(raw)
    {
        console.log(raw);
        let parsed = this.regex.exec(raw);

        this.id = Number(parsed[1]);
        this.steamid = parsed[2];
        this.url = parsed[3];
    }

    toString()
    {
        return HTTP.name;
    }

    static clean(lua)
    {
    }

    process(lua)
    {
        if (!blacklist)
            return;

        let steamid = this.steamid;

        lua.emit("LuaLog", this.steamid, "User http requests " + this.url);
        /*
        if (bot.Client.users) {
            var userinfo = bot.Client.users[steamid];
            var username = userinfo ? userinfo.playerName : steamid;
            console.log(username + " [" + steamid.toString() + "] HTTP request: " + this.url);
        }
        */

        let parsed = url.parse(this.url);

        let id = this.id;

        if (!parsed)
            lua.queueCommand("HTTPCallback( " + id + ", 0, '', " + lua.luaQuote("Domain unresolved") + ")", false, true);

        else if (parsed.auth && parsed.auth !== "")
            lua.queueCommand("HTTPCallback( " + id + ", 0, '', " + lua.luaQuote("Auth rejected") + ")", false, true); // TROLLED

        else if (parsed.protocol !== "http:" && parsed.protocol !== "https:")
            lua.queueCommand("HTTPCallback( " + id + ", 0, '', " + lua.luaQuote("Invalid protocol") + ")", false, true);

        else if (!parsed.hostname || blacklist.indexOf(parsed.hostname) > -1)
            lua.queueCommand("HTTPCallback( " + id + ", 0, '', " + lua.luaQuote("Hostname blacklist") + ")", false, true);

        else
        {
            let id = this.id;
            let http_url = this.url;
            dns.lookup(parsed.hostname, (err, addr, fam) => {

                if(err)
                {
                    lua.queueCommand("HTTPCallback( " + id + ", 0, '', " + lua.luaQuote(err.toString()) + ")", false, true);
                    return;
                }

                if(blacklist.indexOf(addr) > -1)
                {
                    lua.queueCommand("HTTPCallback( " + id + ", 0, '', " + lua.luaQuote("IP blacklist") + ")", false, true);
                    return;
                }

                setTimeout((id, http_url) => {

                    let http_request_options = {
                        url: http_url,
                        headers: {
                            "User-Agent": "Some Dank Fuckin' GLua Coders (Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; GTB7.4; InfoPath.2; SV1; .NET CLR 3.3.69573; WOW64; en-US))"
                        }
                    };

                    request(http_request_options, (err, status, body) => {
                        if(err)
                        {
                            lua.queueCommand("HTTPCallback( " + id + ", 0, '', " + lua.luaQuote(err.toString()) + ")", false, true);
                            return;
                        }

                        lua.queueCommand("HTTPCallback(" + id + ", " + status.statusCode + ", " + lua.luaQuote(body) + ")", false, true);

                    });
                }, 1, id, http_url);

            });
        }
    }

}

module.exports = HTTP;
