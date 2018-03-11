<device>
<ul class='mdl-list'>
<li if={!enable}>
	<span class="mdl-list__item-primary-content">
		<i class="material-icons mdl-list__item-avatar">sync_disabled</i>
		<span class="muted">{device.address.slice(0,4)} | {device.advertisementData.kCBAdvDataLocalName.slice(8,12)} </span>
		<span class="mdl-list__item-sub-title"> Disabled </span>
	</span>
</li>
<li if={enable} class="mdl-list__item mdl-list__item--two-line" >
	<span class="mdl-list__item-primary-content">
      <i class="material-icons mdl-list__item-avatar">person</i>
      <span>{device.address.slice(0,4)} | {userDevicePreferences.location.slice(0,4)} | {device.advertisementData.kCBAdvDataLocalName.slice(8,12)}</span>
      <span class="mdl-list__item-sub-title"> <span class={strong:userNotification} onclick={setUserNotify}>Notify</span> {status} .<span if={timeSinceSync<10000}>
				Synced {timeSinceSync} mins ago
			</span> </span>
    </span>
    <a class="mdl-list__item-secondary-action" onclick={connectDevice} href="#devices"><i class="material-icons">sync</i></a>
</li>
</ul>
	
	<script>
		var self = this
		// deviceTag = this
		self.records = []
		self.MIN_TIME_BETWEEN_SYNCS = 12*60 // 12 hours
		self.device = opts.device
		self.isCompleted = false
		self.messages = {}
		self.receivedData = {}
		self.timeSinceSync = 10000 // minutes. init to high value 
		self.lastSyncTime = new Date("1/1/2000")
		self.userNotification = false
		// enable only if user is assigned
		self.enable = false
		self.userDevicePreferences = {location: ""}




		setUserNotify(){
			self.userNotification = true
			self.update()
		}
		
		devicesTag.on("sendSignal", function(d){
			self.calculateTimeSinceLastSync()
			if (self.device.address == d.deviceAddress)
				self.sync()
		} )

		devicesTag.on("setNotify", function(d){
			if (self.device.address == d.deviceAddress)
				self.setUserNotify()
		} )

		sync(){
			if (self.timeSinceSync>self.MIN_TIME_BETWEEN_SYNCS && self.enable) 
			{
				appTag.log("BLE-SyncingDevice | "+ self.device.address );
				self.connectDevice()
			} else {
				// appTag.log("D: Not yet. " + self.device.address);
			}

		}

		
		this.on("mount", function(){
			self.init()
		})

		init(){
			this.records = []//[{"time":"2017-01-02T16:52:00.000Z","value":"939"}]
			this.status = ""

			console.log(JSON.stringify(self.device));
			self.fetchLastSyncTime()
			self.update()

			let centers = API.getCenters(self.device.address)
			let userWhitelist = API.getUserWhitelist(self.device.address)
			if (userWhitelist.indexOf(appTag.userId)>=0)
			{
				console.log("[BLE-DeviceFound] User is allowed", self.device.address);
				self.enable = true
			}
			else 
			{
				console.log("[BLE-DeviceFound] User not allowed ", self.device.address);
				return
			}

			let up = appTag.userPreferences
			if (!up.devices[self.device.address]){
					up.devices[self.device.address] = {
						address: self.device.address,
						location: "", 
						a1:"1", a2:"2", a3:"3", a4:"4", a5:"5", 
					}
					API.saveUserPreferences()
			}

			self.userDevicePreferences = up.devices[self.device.address]
			self.userDevicePreferences.centers = centers
			self.userDevicePreferences.userWhitelist = userWhitelist
			self.update()
			
		}



		fetchLastSyncTime(){
			var thisDeviceListRef =  firebase.database().ref('users/' + appTag.userId + '/data/'+self.device.address)
			thisDeviceListRef.limitToLast(1).on("child_added", function(snapshot) {
				value = snapshot.val()
				if (value){
					if (value.createTime != undefined){
						self.lastSyncTime = new Date(value.createTime)
						self.calculateTimeSinceLastSync()
					}
					
				}
				
			});
		}

		calculateTimeSinceLastSync(){
			self.timeSinceSync = Math.abs(new Date() - self.lastSyncTime) / 1000 / 60;
			self.timeSinceSync = Math.round(self.timeSinceSync * 100) / 100
			// console.log('Last sync time: ' + self.lastSyncTime);
			self.update()
		}


		connectDevice(){
			if (!self.enable){
				console.log("Device is not enabled");
				return
			}

			self.records = []
			self.updateStatus("Refreshing...")
			self.isCompleted = false

			if (!self.device.__isConnected)
			{			
				app.connect(self.device, function(device){
					self.device.__isConnected = true;
					console.log("Enabling Notifications");
					// get notifications 
					app.enableNotifications(device, function(data){
						message = evothings.ble.fromUtf8(data)
						appTag.log("BLE-MessageReceived | From " + self.device.address + " | Message: " + message);
						if (message.indexOf("reset") >= 0){
							self.device.__isConnected = false
							// check for user notification
							appTag.log("BLE-ClosingDevice | " + self.device.address);
							evothings.ble.close(device)
							self.updateStatus("Done")
						} else 
							self.receiveMessage(message)
					})
				})

			} else {
				app.sendMessage(self.device, app.goMessage());
			}
			self.update()
		}

		receiveMessage(message){
			// Message e.g. 27:D:0:25:24 | D is message Type | Format = TransmissionId:D:IndexOfDataOnDevice:TimeOnDeviceOfData:Value

				var data = message.split(":")
				var dataId = data[0]
				var type = data[1]

				var getTime= function(sensorDataInputTime, signalTimeOnMicrocontroller, signalReceiveTime){
					var minutesSinceDataOnDevice = Number(signalTimeOnMicrocontroller)-Number(sensorDataInputTime);
					var timeForRec = new Date(signalReceiveTime - minutesSinceDataOnDevice*60000);
					timeForRec.setMilliseconds(0);
					timeForRec.setSeconds(0);
					return moment(timeForRec);
				};

				if (type == "C"){
					var count = data[2];
					var deviceSessionId = data[3]
						self.receivedData[dataId] = {"count": count, "records":[], timeStamp : new moment(), deviceSessionId: deviceSessionId};
						if (count==0)
						{
							self.updateStatus( "No records yet", true);	
							self.setData([]);	
						} else 
							self.updateStatus( "Receiving "+ count + " records");	
				}

				if (type=="D" || type == "N"){
					let dataIndex = data[2]
					let sensorDataInputTime = data[3]
					let signalTimeOnMicrocontroller = dataId
					let value = data[4]
					let touchButtonIndex = self.getTouchButtonIndex(value)

					if (type == "D"){
						var signalReceiveTime = self.receivedData[dataId].timeStamp
						var time = getTime(sensorDataInputTime, signalTimeOnMicrocontroller, signalReceiveTime)
						var rec = {deviceSessionId: self.receivedData[dataId].deviceSessionId, message: message, time: time.format(), value: value, dataIndex: dataIndex, deviceAddress: self.device.address, touchButtonIndex: touchButtonIndex, touchButtonLabel: self.getButtonLabel(touchButtonIndex), userDevicePreferences: self.userDevicePreferences}
						rec['uniqueHash'] = time.format() + '-' + self.device.address + "-"+ value
						self.addRec(rec)
						self.receivedData[dataId]["records"].push(rec)
						if (String(self.receivedData[dataId]["records"].length) == self.receivedData[dataId]["count"]){
							self.updateStatus( "Received "+self.receivedData[dataId]["records"].length+" records.", true)
						} else {
							self.updateStatus( self.receivedData[dataId]["records"].length + "/"  + self.receivedData[dataId]["count"]);	
						}
					}
					if (type == "N"){
						// var rec = {time: getTime(sensorDataInputTime, signalTimeOnMicrocontroller, new Date()), value: value, isNew: true};
						// if(Number(value) > 90)
							// app.sendNotification("Record your audio")

						// self.addRec(rec);
					}
				}
		}

		getTouchButtonIndex(softPotValue){
			// There are 7 touch points on the softpotentiometer
			let centers = self.userDevicePreferences.centers;
			
			// find the closes center to the softpotvalue
			let closest = centers.reduce(function (prev, curr) {
			  return (Math.abs(curr - softPotValue) < Math.abs(prev - softPotValue) ? curr : prev);
			});
			return centers.indexOf(closest);
		}

		getButtonLabel(touchButtonIndex){
			

			if (touchButtonIndex == 0)
				return "Activity:Other"
			if (touchButtonIndex == 6)
				return "Social:Yes"

			var ret = "Activity:"+self.userDevicePreferences["a"+touchButtonIndex] || ""

			return ret
		}

		

		updateStatus(message, isCompleted){
			// this.records = []
			this.status = message
			
			if (isCompleted)
			{
				self.isCompleted  = true
				console.log("trigger sync finished: " + self.device.address)

				devicesTag.syncFinished()
				self.status += " | Total " + self.records.length

				if (self.userNotification){
					self.notifyTimeout = setInterval(function(){
						if (self.device.__isConnected){
							app.sendMessage(self.device, "Notify:"+self.records.length); 
						} else {
							window.clearInterval(self.notifyTimeout);
							self.userNotification = false
						}
						self.update()
					}, 5000)
					setTimeout(function(){
						self.device.__isConnected = false
						evothings.ble.close(device)
						self.updateStatus("Idle")
					}, 40000)

				}
				else{
					setTimeout(function(){
							app.sendMessage(self.device, "Done:"+self.records.length);
					}, 1000)
				}
				self.saveDeviceDataToFirebase()
				
			}
			self.update()
		}

		saveDeviceDataToFirebase(){
			
		  var timestamp = new Date()
	      saveObject = {createTime : timestamp.toString(), device: JSON.parse(JSON.stringify(self.device)), records: self.records}

	      var thisDeviceListRef =  firebase.database().ref('users/' + appTag.userId + '/data/'+self.device.address)
	      var newPostKey = thisDeviceListRef.push().key

	      
	      var updates = {};
	      updates['/users/' + appTag.userId + '/data/'+self.device.address + "/" + newPostKey] = saveObject;
	      updates['/users/'+ appTag.userId +'/allrecords/' + newPostKey] = saveObject;

	      _.each(self.records, function(rec){
	      	rec.userPreferences = appTag.userPreferences
	      	updates['/users/' + appTag.userId + '/deviceReports/' + rec.uniqueHash] = rec
	      })

	      firebase.database().ref().update(updates).then(function(){
	      	console.log('BLE-DataSaved', updates);
	      	self.fetchLastSyncTime()
	      })	      

	      devicesTag.trigger("DeviceSyncComplete", {"deviceAddress": self.device.address})
		}

		setData(data){
			this.records = []
			// console.log(_.keys(data));
			var recs = _.flatten(_.pluck(_.values(data),"records"))
			self.records = _.uniq(recs, function(item, key) { 
				return item.time.toISOString();
			});

			self.update()
		}
		addRec(rec){
			console.log(rec);
			appTag.log("BLE-Touch | " + rec.touchButtonLabel, rec)
			self.records.push(rec)
			self.update()
		}
	</script>
	<style scoped>
		.newData {
			color: red;
		}
		<style>
		.demo-card-square.mdl-card {
		  width: 100%;
		  height: 320px;
		}
		.demo-card-square > .mdl-card__title {
		  /*color: #fff;*/
		 
		}
	</style>


</device>