<deviceconfig>
  <div class="container demo-card-wide mdl-card mdl-shadow--4dp">
    <div class="">
    
      <ul>
        <li>Address: {deviceAddress}</li>
      </ul>

      
    </div>
    

    <div class="mdl-card__supporting-text">
      <tb label="Location" onchange={changeLocation} textvalue={deviceSettings.location} />
      
      <tb label="Activity 1" ref="a1" onchange={changeActivity} textvalue={deviceSettings.a1} />
      <tb label="Activity 2" ref="a2" onchange={changeActivity} textvalue={deviceSettings.a2} />
      <tb label="Activity 3" ref="a3" onchange={changeActivity} textvalue={deviceSettings.a3} />
      <tb label="Activity 4" ref="a4" onchange={changeActivity} textvalue={deviceSettings.a4} />
      <tb label="Activity 5" ref="a5" onchange={changeActivity} textvalue={deviceSettings.a5} />
    </div>
    

  </div>
  

  <script>
    var self = this
    deviceconfigtag = this
    self.deviceSettings = opts.device
    self.deviceAddress = opts.address
    

    // console.log(self.device);
    this.on("mount", function(){
      // self.fetchDeviceConfig()
    })

    devicesTag.on("DeviceSyncComplete", function(d){
      if (self.device.address == d.deviceAddress)
        self.sync()
    })

    // fetchDeviceConfig(){
    //   let up = appTag.userPreferences
    //   if (!("devices" in up))
    //     up.devices = {}

    //   var settings = up.devices[self.device.address]
    //   if (settings)
    //     self.deviceSettings = settings
    //   else
    //     up.devices[self.device.address] = self.deviceSettings

    //   self.update()
    // }

    changeLocation(e){
      self.deviceSettings.location = e.target.value
      self.saveDeviceSettings()
    }
    changeActivity(){
      for (var a in self.refs){
        self.deviceSettings[a] = self.refs[a].text
      }
      self.saveDeviceSettings()
    }

    saveDeviceSettings(){
      let up = appTag.userPreferences
      up.devices[self.device.address] = self.deviceSettings
      API.saveUserPreferences()

    }
  </script>
  <style scoped>
    .container {
/*      margin: 1em;*/
    }
    .form {
      margin: 1em;
    }
    tb .mdl-textfield{
      width: 100px;
    }
  </style>
</deviceconfig>