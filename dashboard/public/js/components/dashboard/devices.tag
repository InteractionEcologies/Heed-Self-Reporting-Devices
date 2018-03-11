<devices>

<div class="container">
	<div class="mdl-grid">
	 <!--  <div class="mdl-cell mdl-cell--4-col">
	  	Add devices from list:
	  	<ul>
	  		<li each={device in foundDevices} onclick={addDeviceClick}>
	  			{device}
	  		</li>
	  	</ul>
	  </div> -->
	  <div each={g in groups} class="mdl-cell mdl-cell--4-col">
	  <h3>{g}</h3>
	  	<div each={getDevices(g)} class="mdl-card mdl-shadow--4dp">

	  	  <div class="mdl-card__title">
	  	  {address}
	  	  </div>
	  	  <div class="mdl-card__supporting-text">
	  	    <tb label="points" onchange={changePoints} textvalue={JSON.stringify(touchpoints)} />
	  	    <tb label="whitelist users" onchange={changeWhitelist} textvalue={JSON.stringify(whitelist)} />
	  	    <!-- <tb label="group" onchange={changeGroupId} textvalue={JSON.stringify(groupId)} /> -->
	  	  </div>
	  	</div>
	  </div>
	  <div class="mdl-cell mdl-cell--4-col"></div>
	</div>
</div>

<script>
	var self = this
	devicesTag = this
	self.devices = []
	self.foundDevices = []
	self.firebaseRef = firebase.database().ref('knowndevices/')
	self.groups = ["1","2","3","4"]

	this.on("mount", ()=>{
		self.init()
	})

	getDevices(g){
		return _.filter(self.devices, d=>{
			return d.groupId == g
		})
	}

	init(){
		self.firebaseRef.once('value').then(s => {
			let d = s.val()
			if (d){
				console.log(d);
				self.devices = _.values(d)
				self.update()
			}
		})
	}

	changePoints(e){
		e.item.touchpoints = JSON.parse(e.target.value)
		self.save()
	}

	changeWhitelist(e){
		e.item.whitelist = JSON.parse(e.target.value)
		self.save()
	}

	changeGroupId(e){
		e.item.groupId = JSON.parse(e.target.value)
		self.save()
	}

	appTag.on('logsLoadedlogs', ()=>{
		self.fetchDevicesFromLogs()
	})

	fetchDevicesFromLogs(){
		self.foundDevices = _.chain(clogsTag.logs).filter(d => {return d.text.indexOf('Nearby')>=0}).pluck('data').pluck('bleesmDevices').flatten().pluck('address').union().filter().compact().value()
		self.update()
	}

	addDeviceClick(e){
		let address = e.item.device
		addDevice(address)
	}
	addDevice(address){
		if (_.pluck(self.devices, 'address').indexOf(address)<0){
			var device = {'address': address, touchpoints: [86, 68, 50, 35, 24, 16, 5] }
			self.devices.push(device)
			self.update()
		} else 
			console.log("already added");
	}

	save(){
		var saveObject = {}
		_.each(self.devices, d => {
			saveObject[d.address] = d
		})
		return self.firebaseRef.set(saveObject).then(()=>{console.log("Saved"); console.log(saveObject);})
	}
</script>

</devices>