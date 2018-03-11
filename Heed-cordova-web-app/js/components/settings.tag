<settings>
<div class="settingContainer">
  <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
  <input class="mdl-textfield__input" autocapitalize="off" type="text" id="userid" name="userId" value={appTag.userId} onchange={updateUserId}>
  <label class="mdl-textfield__label" for="userid">UserId</label>
  </div>

  <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
  <input class="mdl-textfield__input" type="text" id="fname" name="fname" value={appTag.userPreferences.fname} onchange={updateUserName}>
  <label class="mdl-textfield__label" for="fname">Name</label>
  </div>

  
    <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
      <input class="mdl-textfield__input" type="text" pattern="-?[0-9]*(\.[0-9]+)?" value={appTag.userPreferences.awakeHour} id="awakeHour" onchange={updateAwakeHour}>
      <label class="mdl-textfield__label" for="awakeHour">Awake Hour (0-24)</label>
      <span class="mdl-textfield__error">Input is not a number!</span>
    </div>

    <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
      <input class="mdl-textfield__input" type="text" pattern="-?[0-9]*(\.[0-9]+)?" value={appTag.userPreferences.sleepHour} id="sleepHour" onchange={updateSleepHour}>
      <label class="mdl-textfield__label" for="sleepHour">Sleep Hour (0-24)</label>
      <span class="mdl-textfield__error">Input is not a number!</span>
    </div>
    <a href="mailto:gparuthi@umich.edu?subject=[BLE-ESM STUDY] Help">Help</a>
    <hr>
    <h4>Developer Options</h4>
   <label if={appTag.isLogRemote=="0"} class="mdl-switch mdl-js-switch mdl-js-ripple-effect" for="switch-1">
    <input type="checkbox" id="switch-1" class="mdl-switch__input" onchange={changeDevMode}>
    <span class="mdl-switch__label">DEV MODE</span>
  </label> 
  <p></p>

  <button class="mdl-button mdl-js-button  mdl-button--colored" onclick={restart} class="ui" waves-center="true">
             Restart
    </button>

    <button class="mdl-button mdl-js-button  mdl-button--colored" onclick={showDevices} class="ui" waves-center="true">
             Devices
    </button>
    <button if={appTag.isLogRemote=="0"} class="mdl-button mdl-js-button  mdl-button--colored" onclick={updateApp} class="ui" waves-center="true">
             Update-App
    </button>

    <div if={appUpdate}>
      Current version: {appUpdate.label} - {appUpdate.appVersion} 
    </div>


  <div if={APP_DEV_MODE}>
    <button class="mdl-button mdl-js-button  mdl-button--colored" onclick={getNotification} class="ui" waves-center="true">
             Get notification
    </button>
  </div>
  
  <div>
  
   
  </div>
</div>


  <script>
   var self = this
   settingsTag = self

   this.on("mount", function(){
			self.init()
		})
   this.on("update", function(){
      appTag.checkForMDL();
    })


   init(){


   	// self.update()
   }

   getNotification(){
    app.startLocalNotifications(true)
   }

   updateAwakeHour(e){
      appTag.userPreferences.awakeHour = e.target.value
      API.saveUserPreferences()
   }

   updateSleepHour(e){
      appTag.userPreferences.sleepHour = e.target.value
      API.saveUserPreferences()
   }

   showDevices(){
    if (appTag.isLogRemote=="1")
      appTag.setLogging(0)
    else 
      appTag.setLogging(1)
   }

   updateApp(){
    codePush.sync(null, { updateDialog: false, installMode: InstallMode.IMMEDIATE });
   }

   

   changeDevMode(){
    appTag.log("DEV_MODE_STARTED")

    APP_DEV_MODE = !APP_DEV_MODE

    // if (APP_DEV_MODE)
    // {
    //   var localNotification = {
    //     id: 100,
    //     title: 'BLE-ESM | DEBUG MODE STARTED',
    //     text: ''
    //   }
    //   cordova.plugins.notification.local.schedule(localNotification);
    // } else {
    //   cordova.plugins.notification.local.clear(100, function(){});
    // }
    appTag.update()
   }


   restart(){
    appTag.log("AppRestart")
    codePush.restartApplication()
   }

    updateUserId(e){
      appTag.userId = e.target.value
      appTag.log("Settings | Username changed to " + appTag.userId)
      window.localStorage.setItem("userId", appTag.userId) 
      location.reload()
    }
    
    updateUserName(e){
      appTag.userPreferences.fname = e.target.value
      API.saveUserPreferences()
    }

  </script>
  <style scoped>
    .settingContainer{
      margin: 1em
    }
  </style>
</settings>
