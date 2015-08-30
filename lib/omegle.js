var http = require('http');
var events = require('events');
var qs = require('querystring');
var util = require('util');

var allowedEvents = [
  'waiting',
  'connected',
  'gotMessage',
  'strangerDisconnected',
  'typing',
  'stoppedTyping',
  'recaptchaRequired',
  'recaptchaRejected',
  'statusInfo',
  'question',
  'antinudeBanned',
  'error'
];

function Omegle(topic) {
  this.userAgent = 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:39.0) Gecko/20100101 Firefox/39.0';
  this.host = 'omegle.com';
  this.topic = topic;
  
  // need our random id
  // taken from omegle itself
  this.randID = function()
  {
      for(var a="",b=0;8>b;b++)
      {
          var c=Math.floor(32*Math.random());
          a=a+"23456789ABCDEFGHJKLMNPQRSTUVWXYZ".charAt(c);
      }
      return a;
  }();
  
  this.topics = ["chatting","gaming","hacking","food","talking","programming","coding"];
  
}

util.inherits(Omegle, events.EventEmitter);

Omegle.prototype.request = function (path, data, callback) {
  var options, req;
  if (data) {
    data = formFormat(data);
  }
  options = {
    method: 'POST',
    host: this.proxy_ip ? this.proxy_ip : this.host,
    port: this.proxy_port ? this.proxy_port : 80,
    path: "http://omegle.com" + path,
    headers: {
      'User-Agent': this.userAgent,
      'Connection': 'Keep-Alive'
    }
  };
  if (data) {
    options.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=utf-8';
    options.headers['Content-Length'] = data.length;
  }
  req = http.request(options, callback);
  if (data) {
    req.write(data);
  }
  return req.end();
};

formFormat = function (data) {
  return qs.stringify(data);
};

getAllData = function (res, callback) {
  var buffer;
  buffer = [];
  res.on('data', function (chunk) {
    buffer.push(chunk);
  });
  res.on('end', function () {
    var data = buffer.join('');
    return callback(data);
  });
};

callbackErr = function (callback, res) {
  return typeof callback === "function" ? callback((res.statusCode !== 200 ? res.statusCode : void 0)) : void 0;
};

Omegle.prototype.start = function (tags, callback) {
  tags = tags && tags.length > 0 ? tags : this.topics;
  
  var topics = JSON.stringify(tags);
  
  
  var _this = this;
  var options = {
    rcs: 1,
    firstevents: 1,
    lang: 'en',
    randid: this.randID,
    topics: topics,
  };
  return this.request('/start?' + qs.stringify(options), void 0, function (res) {
    if (res.statusCode !== 200) {
      if (typeof callback === "function") {
        callback(res.statusCode);
      }
      return;
    }
    return getAllData(res, function (data) {
      data = JSON.parse(data);
      _this.eventReceived(data);
      _this.id = data['clientID'];
      callback();
      _this.emit('newid', _this.id);
      return _this.eventsLoop();
    });
  });
};

Omegle.prototype.setProxy = function(ip, port)
{
    
    this.proxy_ip = ip;
    this.proxy_port = port;
    
}

Omegle.prototype.eventsLoop = function () {
  var _this = this;
  return this.request('/events', {
    id: this.id
  }, function (res) {
    if (res.statusCode === 200) {
      return getAllData(res, function (eventData) {
        return _this.eventReceived(eventData);
      });
    }
  });
};

Omegle.prototype.send = function (msg, callback) {
  return this.request('/send', {
    msg: msg,
    id: this.id
  }, function (res) {
    return callbackErr(callback, res);
  });
};

Omegle.prototype.postEvent = function (event, callback) {
  return this.request("/" + event, {
    id: this.id
  }, function (res) {
    return callbackErr(callback, res);
  });
};

Omegle.prototype.startTyping = function (callback) {
  return this.postEvent('typing', callback);
};

Omegle.prototype.stopTyping = function (callback) {
  return this.postEvent('stopTyping', callback);
};

Omegle.prototype.disconnect = function (callback) {
  this.postEvent('disconnect', callback);
  return this.id = void 0;
};

Omegle.prototype.eventReceived = function (data) {
  if(!data) 
  {
      
      console.log("WARNING: omegle.eventReceived couldn't parse data!: \n\n");
      
      return;
      
  }
  var events = data.events;
  if(!events)
  {
      
      console.log("WARNING: omegle.eventReceived couldn't find event-data\n\n");
      
      return;
      
  }
  for (var i = 0; i < events.length; ++i) {
    var event = events[i][0];
    if (event == 'strangerDisconnected') {
      this.disconnect(function (err) {
        if (err) {
          console.log(err);
        }
      });
    }
    if (allowedEvents.indexOf(event) !== -1) {
      if (events[i][1]) {
        this.emit("event", event, events[i][1]);
        this.emit(event, events[i][1])
      }
      else {
        this.emit("event", event);
        this.emit(event);
      }
    }
  }
  if (this.id) {
    return this.eventsLoop();
  }
};

exports.Client = Omegle;