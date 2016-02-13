"use strict";
const SimpleTimer = class SimpleTimer
{

    get regex()
    {
        return /^([^]+);([^]+)$/;
    }

    constructor(raw)
    {
        let parsed = this.regex.exec(raw);

		this.callbackID      = Number(parsed[1]);
		this.callbackDelayMS = Math.max(Number(parsed[2]) * 1000, 250);
    }

    toString()
    {
        return SimpleTimer.name;
    }

    static clean(lua)
    {
        for (let k in (lua.simpleTimers || {}))
            clearTimeout(lua.simpleTimers[k]);

        delete lua.simpleTimers;
    }

    process(lua)
    {

        lua.simpleTimers = lua.simpleTimers || [];

        let timeout = setTimeout(() => {

            lua.simpleTimers.splice(lua.simpleTimers.indexOf(timeout), 1);

            lua.queueCommand("SimpleTimerCallback( " + this.callbackID + " )", false, false);

        }, this.callbackDelayMS);

        lua.simpleTimers.push(timeout);

    }

}

module.exports = SimpleTimer;
