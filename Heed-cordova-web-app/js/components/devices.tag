<devices>
	<div if={appTag.userPreferences.studyCondition == "OnlyPhone"}>
	<div class="mdl-grid centered">
	  <p>
	    This feature will be available during the second and last stage of the study. 

	    Study team will let you know. Thanks.
	  </p>
	</div>
	</div>
	<div if={appTag.userPreferences.studyCondition != "OnlyPhone"}>	
		<div id="startView">
			<button class="mdl-button mdl-js-button  mdl-button--colored" onclick={startScan} class="ui" waves-center="true">
				Scan
			</button>
			<button class="mdl-button mdl-js-button  mdl-button--colored" onclick={disconnect}>
				Disconnect
			</button>
			<button class="mdl-button mdl-js-button  mdl-button--colored" onclick={reset}>
				Reset
			</button>
		</div>

		<div id="scanResultView" hide={devices.length > 0}></div>

		<div id="conversationView" >
			<div if={isScanning}>
				<img src="img/loader_small.gif" style="display:inline; vertical-align:middle">
				<!-- <p style="display:inline">   Scanning...</p> -->
			</div>

			<ul class='mdl-list'>
			    <device each={device in devices} device={device}></device>
			</ul>
			<div if={devices.length==0 && !isScanning}>
				No nearby devices found.
			</div>
			

		</div>
		<div aria-live="assertive" aria-atomic="true" aria-relevant="text" class="mdl-snackbar mdl-js-snackbar">
			<div class="mdl-snackbar__text"></div>
			<button type="button" class="mdl-snackbar__action"></button>
		</div>
	</div>
	
	<script>
		var self = this
		devicesTag = this
		self.status = ""

		self.devices = []
		self.allNearbyDevices = [] // may help keep track of location of the user

		self.syncQueue = []
		

		self.isScanning = false

		this.on("mount", function(){
			self.init()
		})

		syncFinished(){
			if (self.syncQueue.length>0)	
				self.sync()
		}

		startSync(){
			if (self.syncQueue.length > 0)
				self.sync()
			else 
			{
				if (self.devices.length > 0 ){
					self.syncQueue = self.devices.slice()
					self.sync()
				}
			}
		}

		sync(){
			// sync the next one
			var nextDevice = self.syncQueue.pop()
			// appTag.log("DM: Can this device sync? "+ nextDevice.address);
			if (nextDevice)
			{
				self.trigger('sendSignal', {"deviceAddress": nextDevice.address})
			}	
			self.update()
		}

		startScanSyncTimer(){
			// start scan after 5 seconds of loading
			setTimeout(function(){
				self.startScan()
			}, 5000);
			// after every 2 minutes
			// self.scanInterval = setInterval(function(){
			// 	self.startScan()
			// }, 120000);
			// As a workaround, try to sync every 10 seconds. The device controller decides wether to actually sync or not
			setInterval(function(){
				self.startSync()
			}, 10000);
		}

		init(){
			self.startScanSyncTimer()
			console.log('Device Scan log started.')
		}

		
		startScan(){
			if (!self.isScanning){
				self.disconnect()
				self.isScanning = true
				self.off("*")

				self.updateDeviceList()
				if (typeof(app) != "undefined")
					app.startScan(self.onScanComplete)
				self.update()
			}
			
		}

		updateDeviceList(){
			self.devices = _.filter(self.devices, function(d){
				var minutesSinceSeen = moment().diff(moment(d.seenAt), "minutes")
				if (minutesSinceSeen<12)
					return true
				return false
			})
		}

		onScanComplete(){
			console.log("Scanning Finished")
			self.isScanning = false
			var timestamp = new Date()
			let bleesmDevices = _.pluck(self.devices, 'address')
			saveObject = {createTime : timestamp.toString(), bleesmDevices: JSON.parse(JSON.stringify(self.devices)), allNearbyDevices: JSON.parse(JSON.stringify(self.allNearbyDevices))}
			var nearbyDeviceListRef =  firebase.database().ref('users/' + appTag.userId + '/nearbyDevices/')
			var newSearchResultRef = nearbyDeviceListRef.push()
			var postId = newSearchResultRef.key;
			saveObject.postId = postId;
			newSearchResultRef.set(saveObject).then(function(){
				appTag.log('BLE-NearbyDeviceSearch | Found | ' + bleesmDevices, saveObject);
				self.allNearbyDevices = []
			})
		}



		addDevice(device){
			console.log(device.address);
			// console.log(self.devices);

			self.devices = _.reject(self.devices, function(el) { return el.address === device.address })
			  self.devices.push(device)
			  self.update()			
		}

		tryAgain(device){
			self.syncQueue.push(device)
		}


		updateStatus(status){
			// appTag.log(status)
			// var notification = document.querySelector('.mdl-js-snackbar');
			// notification.MaterialSnackbar.showSnackbar(
			// {
			// 	message: status
			// }
			// );
			self.log(status)
			self.update()
			
		}

		log(m){
			appTag.log(m)
			self.update()
		}

		disconnect(reset){
			self.isScanning = false
			app.stopScan()

			_.each(self.devices,function(d){
				evothings.ble.close(d)
			})

			if (reset==true)
				self.devices = []
			self.update()
		}

		reset(){
			appTag.log("BLE-RESET");
			self.disconnect(true)
			evothings.ble.reset()
			appTag.loadUserPreferences()
		}

		notifyNearbyDevices(){
			self.disconnect()

			let nearbyDeviceAddresses = _.pluck(self.devices, 'address')

			
			appTag.log("BLE-NotifyingNearbyDevices | " + nearbyDeviceAddresses)
			_.each(self.tags.device, function(deviceTag){
				// console.log(deviceTag);
				if (deviceTag.enable){
					deviceTag.setUserNotify()
					deviceTag.connectDevice()
				}
			})	
			
				
			return nearbyDeviceAddresses;
		}
		


	</script>
	<style scoped>
		.newData {
			color: red;
		}
	</style>


</script>
<style scoped>

</style>
</devices>