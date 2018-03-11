
var myService;


function handleSuccess(data) {
	updateView(data);
}

function handleError(data) {
	appTag.log("MyService | Error | " + data.ErrorMessage);
	console.log(JSON.stringify(data));
	updateView(data);
}

			/*
			 * Button Handlers
			 */ 			
			 function getStatus() {
			 	myService.getStatus(	function(r){handleSuccess(r)},
			 		function(e){handleError(e)});
			 };

			 function startService() {
			 	myService.startService(	function(r){handleSuccess(r)},
			 		function(e){handleError(e)});
			 }

			 function stopService() {
			 	myService.stopService(	function(r){handleSuccess(r)},
			 		function(e){handleError(e)});
			 }

			 function enableTimer() {
			 	myService.enableTimer(	60000,
			 		function(r){handleSuccess(r)},
			 		function(e){handleError(e)});
			 }

			 function disableTimer() {
			 	myService.disableTimer(	function(r){handleSuccess(r)},
			 		function(e){handleError(e)});
			 };

			 function registerForBootStart() {
			 	myService.registerForBootStart(	function(r){handleSuccess(r)},
			 		function(e){handleError(e)});
			 }

			 function deregisterForBootStart() {
			 	myService.deregisterForBootStart(	function(r){handleSuccess(r)},
			 		function(e){handleError(e)});
			 }

			 function registerForUpdates() {
			 	myService.registerForUpdates(	function(r){handleSuccess(r)},
			 		function(e){handleError(e)});
			 }

			 function deregisterForUpdates() {
			 	myService.deregisterForUpdates(	function(r){handleSuccess(r)},
			 		function(e){handleError(e)});
			 }

			 function setConfig(helloToString) {
			 	var config = { 
			 		"HelloTo" : helloToString 
			 	}; 
			 	myService.setConfiguration(	config,
			 		function(r){
			 			console.log(r)
			 		},
			 		function(e){
			 			console.log(e)
			 		});
			 }

			/*
			 * View logic
			 */
			 function updateView(data) {
			 	serviceData = data

			 	if (APP_DEV_MODE)
				 	console.log(data);

				setConfig("HEED | " + app.isConnected)
			 	appTag.log("Ping", data);
			 	app.serviceCallback();
			 	if (data.LatestResult)
				 	if (data.LatestResult.AppStartedByService)
					 	cordova.plugins.backgroundMode.moveToBackground()
					if (data.LatestResult.ScreenOff)
						if (data.LatestResult.ScreenOff === true)
							cordova.plugins.backgroundMode.configure({ silent: false, title: "HEED", text:"This helps to keep the app alive." });
						else 
							cordova.plugins.backgroundMode.configure({ silent: true, title: "HEED", text:"This helps to keep the app alive." });
			 	
			 }
