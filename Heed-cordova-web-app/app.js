document.addEventListener(
	'deviceready',
	function() { evothings.scriptsLoaded(app.initialize) },
	false);

var app = {};

app.isConnected = true

app.offlinelogs = []

app.initialize = function()
{
	app.startLocalNotifications();

	app.setConnectionStatusChanges();

	app.initBatteryStatusLogging();

	app.initService();

	app.initServiceCallback();

	app.initActivityUpdates();

	cordova.plugins.backgroundMode.enable();
	cordova.plugins.backgroundMode.configure({ silent: false, title: "HEED", text:"Notification helps to keep the app alive." });
	cordova.plugins.backgroundMode.overrideBackButton();

	codePush.sync(null, { updateDialog: false, installMode: InstallMode.IMMEDIATE });
	codePush.getCurrentPackage(function (update) {
        settingsTag.appUpdate = update;
        settingsTag.update();
        appTag.log("AppInit | " + update.label, JSON.stringify(update));
      });


};

app.initService = function(){
	if (cordova.plugins.myService){
		myService = cordova.plugins.myService;
		myService.startService();
	}
	
	getStatus();
	enableTimer() ;
	registerForUpdates();
	registerForBootStart();
	setConfig("BLE-ESM");

	document.addEventListener("resume", function () {
	    appTag.log('[AppInFG]'); 
	    // codePush.sync(null, { updateDialog: false, installMode: InstallMode.IMMEDIATE });
	});

	document.addEventListener("pause", function () {
	    appTag.log('[AppInBG]');
	});
}

app.initServiceCallback = function(){
	// app.testTimer = new TimedMethod(60, function(){
	// 		appTag.log("Ping");
	// 	});
	app.scanTimer = new TimedMethod(5*60, function(){
			devicesTag.startScan();
		});
	app.notificationTimer = new TimedMethod(10*60, function(){
			devicesTag.startScan();
			app.sendActivityNotification();
		});
	app.refreshTransactionsTimer = new TimedMethod(15*60, function(){
			if(!devicesTag.isScanning){
				devicesTag.reset();
			}
			API.getCurrentLocation("Every15Mins");
		});
	app.getContext = new TimedMethod(60, function(){
		app.checkGetContext();
	})
}

app.serviceCallback= function(){
	// app.testTimer.check();
	app.scanTimer.check();
	app.notificationTimer.check();
	app.refreshTransactionsTimer.check();
	app.getContext.check();

	// clear notifications in case
	cordova.plugins.notification.local.clearAll(function(){
		console.log("AppNotification | Notification cleared")
	});
}

app.initActivityUpdates = function(){
	let s = function(d){
		appTag.log("ActivityUpdate", d);
	}
	cordova.plugins.ActivityRecognition.Connect(function(d){
		console.log(d)
		cordova.plugins.ActivityRecognition.StartActivityUpdates(30000,s,s)
	})
}

app.checkGetContext = function(){
	cordova.plugins.ActivityRecognition.GetActivity(function(d){
		appTag.log("ActivityUpdate | " + d.ActivityType, d)
	})
}

app.initBatteryStatusLogging = function(){
	window.addEventListener("batterystatus", onBatteryStatus, false);

	function onBatteryStatus(status) {
	    appTag.log("BatteryStatus | Level: " + status.level + " isPlugged: " + status.isPlugged, status);
	}
}

app.setConnectionStatusChanges = function(){
	// since I can connect from multiple devices or browser tabs, we store each connection instance separately
	// any time that connectionsRef's value is null (i.e. has no children) I am offline
	var myConnectionsRef = firebase.database().ref('users/'+appTag.userId+'/connections');

	// stores the timestamp of my last disconnect (the last time I was seen online)
	var lastOnlineRef = firebase.database().ref('users/'+appTag.userId+'/lastOnline');

	var connectedRef = firebase.database().ref('.info/connected');
	connectedRef.on('value', function(snap) {
		app.isConnected = snap.val();
	  if (snap.val() === true) {
	    // We're connected (or reconnected)! Do anything here that should happen only if online (or on reconnect)
	    if (app.offlinelogs.length > 0){
		    appTag.log("OfflineLogs", app.offlinelogs)
		    app.offlinelogs = []
	    }

	    // add this device to my connections list
	    // this value could contain info about the device or a timestamp too
	    var con = myConnectionsRef.push(true);

	    // when I disconnect, remove this device
	    con.onDisconnect().remove();

	    // when I disconnect, update the last time I was seen online
	    lastOnlineRef.onDisconnect().set(firebase.database.ServerValue.TIMESTAMP);
	  } else {
	  	appTag.log("AppIsOffline")
	  	// app.checkIfStillOfflineInterval = setInterval(function(){

	  	// }, )
	  }
	});
}

// BLE CODE

app.SCAN_DURATION = 15000;

app.RBL_SERVICE_UUID = '713d0000-503e-4c75-ba94-3148f18d941e';
app.RBL_CHAR_TX_UUID = '713d0002-503e-4c75-ba94-3148f18d941e';
app.RBL_CHAR_RX_UUID = '713d0003-503e-4c75-ba94-3148f18d941e';
app.RBL_TX_UUID_DESCRIPTOR = '00002902-0000-1000-8000-00805f9b34fb';


app.lastMessage = -1;

app.sendMessage = function(device, message)
{
		

		function onMessageSendSucces()
		{
			console.log('Succeded to send message. ' +  message);
		}

		function onMessageSendFailure(errorCode)
		{
			// Write debug information to console
			console.log('Error in sending message '+ message +' - ' + errorCode);
		}
		var service = evothings.ble.getService(device, app.RBL_SERVICE_UUID)
		var characteristic = evothings.ble.getCharacteristic(service, app.RBL_CHAR_RX_UUID)

		_.each(devicesTag.devices,function(d){
			if (d.address == device.address){
				appTag.log("BLE-SendingMessage | Message =\""+ message + "\" | To = " + device.address);
				evothings.ble.writeCharacteristic(
				        device,
				        characteristic,
				        evothings.ble.toUtf8(message),
				        onMessageSendSucces,
				        onMessageSendFailure);
			}	
		})
	
};


app.setLoadingLabel = function(message)
{
	console.log(message);
	$('#loadingStatus').text(message);
};
	

app.syncTimer = null;

app.knownDevices = {};

app.stopScan = function(){
	// stop scanning first
	evothings.ble.stopScan();
	app.isScanning = false;
	clearTimeout(app.scanTimer);
	app.knownDevices = {};
}

app.startScan = function(onScanComplete)
{
	app.stopScan();
	app.isScanning = true;

	// start sync timer. This will stop scanning and trigger onScanComplete
	app.syncTimer = setTimeout(function(){
		app.stopScan();
		onScanComplete();
	}, app.SCAN_DURATION);

	console.log("BLE-ScanStarted")

	function onScanSuccess(device)
	{
		//address, rssi, name, scanRecord
		if (app.knownDevices[device.address])
		{
			return;
		}
		app.knownDevices[device.address] = device;
		devicesTag.allNearbyDevices.push(device)

		if (device.address != null)
		{
			console.log('Found Device: ' + device.address + " " + device.name);
			
			device.seenAt = (moment()).format()

			if (String(device.name).indexOf("BLE-ESM") >= 0 || String(device.name).indexOf("DFU") >= 0 ){
				devicesTag.addDevice(device);
			}
		}
	};

	function onScanFailure(errorCode)
	{
		console.log('startScan error: ' + errorCode);
	};

	evothings.ble.startScan(onScanSuccess, onScanFailure);

	// $('#startView').hide();
};

app.connect = function(device, onConnectSuccess)
{
    evothings.ble.connectToDevice(
        device,
        onConnected,
        onDisconnected,
        onConnectError)

    function onConnected(device)
    {
        console.log('Connected to device');

        app.sendMessage(device, "connected now");

        // Enable notifications for Luxometer.
        onConnectSuccess(device);
    }

    // Function called if the device disconnects.
    function onDisconnected(error)
    {
        console.log('Device disconnected')
    }

    // Function called when a connect error occurs.
    function onConnectError(error)
    {
        console.log('Connect error: ' + error)
    }
}

app.goMessage = function(){
	let curHour = moment().hour()
	let awakeHour = appTag.userPreferences.awakeHour
	let sleepHour = appTag.userPreferences.sleepHour
	let ctTwoDigits = function(myNumber){ return ("0" + myNumber).slice(-2);	}
	return "Go:" + ctTwoDigits(curHour) + ":" + ctTwoDigits(awakeHour) + ":" + ctTwoDigits(sleepHour);
}


app.enableNotifications = function(device, onSuccessNotification)
{
    // Get Luxometer service and characteristics.
    var service = evothings.ble.getService(device, app.RBL_SERVICE_UUID)
    
    var dataCharacteristic = evothings.ble.getCharacteristic(service, app.RBL_CHAR_TX_UUID)

        // Enable notifications from the Luxometer.
    evothings.ble.enableNotification(
        device,
        dataCharacteristic,
        onSuccessNotification,
        onNotificationError);

    app.sendMessage(device, app.goMessage());
   
    function onNotificationError(error)
    {
        console.log('Notification error: ' + error)
    }
}

receivedData = [];

app.sendNotification = function(message){
	let id = Math.round(Math.random()*1000)
	var localNotification = {
		    id: id,
            title: 'HEED Research App',
            text: 'Message is: ' + message
        };
        cordova.plugins.notification.local.schedule(localNotification);
     return id;
}


checkIfSleeping = function(c, s, e){
	
	if  (s <= e)
		return c>=s && (c < e)
	else 
		return c>=s || c < e

}

app.sendActivityNotification = function(){
		
		timestamp = new moment()
		let curHour = timestamp.hour()
		let sleepHour = parseInt(appTag.userPreferences.sleepHour)
		let awakeHour = parseInt(appTag.userPreferences.awakeHour)

		if (appTag.lastNotifyTime)
			lastNotifyTime = moment(appTag.lastNotifyTime);
		else 
			lastNotifyTime = moment().subtract(1, 'days');

		if (checkIfSleeping(curHour, sleepHour, awakeHour))
		{
			appTag.log("AppNotification | Sleep hours right now", {params: [curHour,  sleepHour, awakeHour], userPreferences: appTag.userPreferences})
		} else {
			// check if its been more than 40 minutes
			if ((timestamp-lastNotifyTime) > 40 * 1000 * 60){
				let studyCondition = appTag.userPreferences.studyCondition

				let notifiedDevices = []
				// Trigger Device Notification
				if (studyCondition != appTag.StudyConditions.OnlyPhone){
					let notificationData = {routeId: "report", timestamp: timestamp.format(), 
								studyCondition: studyCondition, 
								curHour:curHour, 
								userPreferences: appTag.userPreferences};
					notifiedDevices = devicesTag.notifyNearbyDevices(notificationData) ;
				}
					
					
				
				// App Notification
				if (studyCondition != appTag.StudyConditions.OnlyDevice)
					setTimeout(function(){
						app.sendAppNotification()
					}, 15000) // usually takes about 15 seconds to sync with devices around

				appTag.lastNotifyTime = timestamp.format()
				app.reportNotificationContext(notifiedDevices)				
				API.saveLastNotifyTime()
				appTag.log("AppNotificationSuccess", {timestamp:timestamp.format(), lastNotifyTime:lastNotifyTime.format()})
				
			}  else {
				appTag.logc('AppNotification | Not been more than 40 minutes', {timestamp:timestamp.format(), lastNotifyTime:lastNotifyTime.format()})
			}
			
		} 
	};

app.sendAppNotification = function(notificationData){
		notificationData = notificationData || {};
		var localNotification = {
			id: 0,
	      title: 'HEED Research App | Report activity',
	      text: 'What were you upto?',
	      data: notificationData
	    };
	    cordova.plugins.notification.local.schedule(localNotification);
	    console.log(localNotification);
	    appTag.log("AppNotification | User Notified on App ", notificationData)
	    setTimeout(function(){
	    	// cancel notification after one minute
	    	cordova.plugins.notification.local.clearAll(function(){
	    		appTag.log("AppNotification | Notification cleared")
	    	});
	    }, 60000);
}

app.startLocalNotifications = function(debug){

	 cordova.plugins.notification.local.clearAll();

	 cordova.plugins.notification.local.on("click", function (notification) {
	 	data = notification.data;
	 	if (data){
	 		console.log(data);
 			data['respondedAt'] = (new Date()).toString();
 			appTag.log("NotificationResponded", data);
 			app.resetNotificationTimer();
 		    document.getElementById("tab_report").click();
	 	}
	 });

	
	// app.resetNotificationTimer();
	if (debug)
		setTimeout(app.sendActivityNotification, 2000);
  }
  app.resetNotificationTimer = function(){
  	app.notificationTimer.reset()
  }

 app.reportNotificationContext = function(notifiedDevices){
      var timestamp = new Date()
      app.reportToStore = {
            devicesNotified: notifiedDevices,
            userPreferences: appTag.userPreferences,
            createTime: timestamp.toString(),           
          }

      function reportNotification(location){
        if (location)
          app.reportToStore['gps_location'] = location
        
          API.reportNotification(app.reportToStore).then(function(ref){
            appTag.log('NotificationContext | ', JSON.stringify(app.reportToStore))
            
          }, function(error){
            appTag.log('NotificationContext | Error', JSON.stringify(error))
          })
      }
      API.getCurrentLocation("NotificationContext").then(function(pos){
             var gpsloc = pos
             API.reportLocation(gpsloc).then(function(){
               console.log('NotificationContextLocation | ', JSON.stringify(gpsloc))  
               reportNotification(gpsloc)
             })

           }, function(error){
            console.log('NotificationContextLocation | Error', JSON.stringify(error)) 
            reportNotification() 
           })
       
       


    }
