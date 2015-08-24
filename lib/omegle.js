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
  
  this.topics = '["chatting","gaming","hacking","food"]';
  
}

util.inherits(Omegle, events.EventEmitter);

Omegle.prototype.request = function (path, data, callback) {
  var options, req;
  if (data) {
    data = formFormat(data);
  }
  options = {
    method: 'POST',
    host: this.host,
    port: 80,
    path: path,
    headers: {
      'User-Agent': this.userAgent,
      'Connection': 'Keep-Alive'
    }
  };
  if (data) {
    options.headers['Content-Type'] = 'application/x-www-form-urlencoded';
    options.headers['Content-Length'] = data.length;
  }
  req = http.request(options, callback);
  if (data) {
    req.write(data);
  }
  return req.end();
};

formFormat = function (data) {
  return ((function () {
    var _results;
    _results = [];
    for (var key in data) {
      var value = data[key];
      _results.push("" + key + "=" + value);
    }
    return _results;
  })()).join('&');
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

Omegle.prototype.start = function (callback) {
  var _this = this;
  var options = {
    rcs: 1,
    firstevents: 1,
    lang: 'en',
    randid: this.randID,
  };
  if (this.topics != null) {
    options['topics'] = this.topics;
  }
  return this.request('/start?' + qs.stringify(options), void 0, function (res) {
    if (res.statusCode !== 200) {
      if (typeof callback === "function") {
        callback(res.statusCode);
      }
      return;
    }
    return getAllData(res, function (data) {
      data = JSON.parse(data);
      setTimeout(_this.eventReceived(JSON.stringify(data['events'])), 100);
      _this.id = data['clientID'];
      callback();
      _this.emit('newid', _this.id);
      return _this.eventsLoop();
    });
  });
};

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

Omegle.prototype.eventReceived = function (_data) {
  data = JSON.parse(_data);
  if(!data) 
  {
      
      console.log("WARNING: omegle.eventReceived couldn't parse data!: \n\n" + _data.toString())
      
      return;
      
  }
  for (var i = 0; i < data.length; ++i) {
    var event = data[i][0];
    if (event == 'strangerDisconnected') {
      this.disconnect(function (err) {
        if (err) {
          console.log(err);
        }
      });
    }
    if (allowedEvents.indexOf(event) !== -1) {
      if (data[i][1]) {
        this.emit(event, data[i][1])
      }
      else {
        this.emit(event);
      }
    }
  }
  if (this.id) {
    return this.eventsLoop();
  }
};

exports.Client = Omegle;