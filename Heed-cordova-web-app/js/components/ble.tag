<ble>
  <div class="blecontainer">
    <devices></devices>

    <h4 onclick={showDevicesToggle}>All Known Devices</h4>
    <div if={showDevices}>
      <deviceconfig each={device, address in appTag.userPreferences.devices} device={device} address={address}>
    </deviceconfig>
    </div>

    
  </div>
  
  <script>
  var self = this


  self.showDevices = true

  showDevicesToggle(){
    self.showDevices = !self.showDevices
    
   }

  
  </script>

  <style scoped>
    .blecontainer{
          margin: 1em;
    }
  </style>
</ble>
