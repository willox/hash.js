var request = require('request');

bot.on("Message",function(name,steamID,msg,group) {
    // match a subreddit + commentID
    var match = msg.match(/\/r\/([a-z0-9]*)\/(?:comments\/)?([a-z0-9]*)(?:\/?.*?)?/i);

    //if there is no valid regex matching, then abort
    if(!match)
        return;

    //if the commentID or subreddit is missing, then abort
    if(!match[2])
        return;

    //launch a request to reddit's JSON api
    request("http://www.reddit.com/" + match[2] + ".json",function(err,resp,body) {
        if(err)
            return; //Abandon ship

        //Parse the received data
        var j_data = JSON.parse(body);

        if(!j_data[0] || !j_data[0].data || !j_data[0].data.children || !j_data[0].data.children[0] || !j_data[0].data.children[0].data)
            return; //Abandon ship

        var thread_data = j_data[0].data.children[0].data;

        var title = thread_data.title;
        var upvote_perc = thread_data.upvote_ratio * 100;
        var nsfw = thread_data.over_18;

        var isNSFW = "";

        if(nsfw)
            isNSFW = " Warning! This link is NSFW.";

        bot.sendMessage("Reddit: \"" + title + "\" [" + upvote_perc + "% upvoted]" + isNSFW,group);
    });
});
