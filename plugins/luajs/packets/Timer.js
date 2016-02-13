"use strict";
const Timer = class Timer
{

    get regex()
    {
        return /^([^]+?);([^]+?);([^]*)$/;
    }

    constructor(raw)
    {
        let parsed = this.regex.exec(raw);

		this.callbackReps    = Number(parsed[1]);
		this.callbackDelayMS = Math.max(Number(parsed[2]) * 1000, 200);
		this.callbackID      = parsed[3];
    }

    toString()
    {
        return Timer.name;
    }

    static clean(lua)
    {
        for (let k in lua.complexTimers)
            clearInterval(lua.complexTimers[k]);

        delete lua.complexTimers;
    }

    process(lua)
    {
        lua.complexTimers = lua.complexTimers || {};

        let timeout = setInterval(() => {

            let final = false;

            if (--this.callbackReps == 0)
            {
                final = true;
                clearInterval(lua.complexTimers[this.callbackID]);
                delete lua.complexTimers[this.callbackID];
            }

            lua.queueCommand("TimerCallback(" + lua.luaQuote(this.callbackID)
                + ", " + (final ? "true" : "false") + ")", false, false);

        }, this.callbackDelayMS);

        if (lua.complexTimers[this.callbackID])
            clearInterval(lua.complexTimers[this.callbackID]);

        lua.complexTimers[this.callbackID] = timeout;
    }

}

module.exports = Timer;
