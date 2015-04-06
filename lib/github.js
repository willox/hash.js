var Notifications	= require( "github-notifications" );
var request			= require( "request" );

Notifications.prototype.markAsRead = function() {

	request.put( {
		url: "https://api.github.com/notifications",
		headers: this._headers
	} );

}

module.exports = Notifications;