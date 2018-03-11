API = {}

API.fetchUserData = function(path, success, error){
		console.log("Fetching all activities for " + appTag.userId +"...");
		var ref = firebase.database().ref('users/' + appTag.userId + '/' + path + '/')
		ref.once('value').then(function(snapshot){
			var data = snapshot.val();
			if (data!=null){
				success(data);
			} else {
				if (error)
					error();
			}
		});
	}

API.reportActivity = function(activity, success){
	return firebase.database().ref('users/' + appTag.userId + '/activities').push().set(activity);
}

API.reportNotification = function(report, success){
	return firebase.database().ref('users/' + appTag.userId + '/notifications').push().set(report);
}

API.reportLocation = function(location, success){
	return firebase.database().ref('users/' + appTag.userId + '/locations').push().set(location);
}

API.saveUserPreferences = function(fromText){
	var prefs = appTag.userPreferences;
	fromText = fromText || "";

	// Dont save the preferences without firstname. This is added to prevent a bug of default preferences being overwritten.
	if (prefs.fname=="")
		return 
	var ref = firebase.database().ref('users/' + appTag.userId + '/preferences');
	ref.set(prefs).then(function(){
		appTag.log('SavedUserPreferences | ' + fromText, prefs);
	}, function(error){
		appTag.log("SavedUserPreferences | error", error);
	})
}

API.saveLastNotifyTime = function(){
	var saveObject = {lastNotifyTime: appTag.lastNotifyTime};
	var ref = firebase.database().ref('users/' + appTag.userId + '/lastNotifyTime').set(saveObject).then(function(){
		appTag.log('LastNotifyTimeUpdated', saveObject);
	}, function(error){
		appTag.log("LastNotifyTimeUpdated | error", error);
	})
}

API.loadAllData = function(success){
	return firebase.database().ref('users/' + appTag.userId).once('value');
}

API.loadUserPreferences = function(success){
	return firebase.database().ref('users/' + appTag.userId + '/preferences').once('value');
}

API.loadLastNotifyTime = function(success){
	return firebase.database().ref('users/' + appTag.userId + '/lastNotifyTime').once('value');
}

API.loadGlobalDevices = function(success){
	return firebase.database().ref('knowndevices').once('value');
}



API.parseLocation = function(pos){
	if (pos.coords){
		let timestamp = moment()
		return {latitude: pos.coords.latitude, longitude: pos.coords.longitude, timestamp: timestamp.format()}
	} else {
		console.error("Can not parse location. ", pos)
	}
}

API.getCurrentLocation = function(sometext){
	sometext = sometext || ""
	let promise = new Promise((resolve, reject) => {
	    navigator.geolocation.getCurrentPosition(function(pos) {
	    	var location = API.parseLocation(pos)
	    	appTag.log("GetCurrentLocation | " + sometext, location);
	    	resolve(location)
	    }, function(error) {
	     	appTag.log("GetCurrentLocation | " + sometext +  "| Error | " + error, error)
	    });
	});
	return promise;
	
}

API.getCenters= function(address) {
	let d = appTag.knownDeviceSettings[address]  
	if (d)
		if (d.touchpoints)
			return d.touchpoints

	return [86, 68, 50, 35, 24, 16, 5]
}

API.getUserWhitelist= function(address) {
	let d = appTag.knownDeviceSettings[address]  
	if (d){
		if (d.whitelist)
			return d.whitelist
		else 
			return ["Gpmoto2"]

	}
}

