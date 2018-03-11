<app>

<div  if={userId=="testuser"} class="page-content">
<main class="mdl-grid mdl-layout__content">
<div style="text-align: center;">
  <div >
    <h4>Welcome to HEED RESEARCH APP</h4>
  </div> 

  <div class="mdl-card__supporting-text" >
  <p>Please enter your username to get started</p>
    <tb label="Username" onchange={settingsTag.updateUserId} ></tb>
  </div>
  <div>
    <button class="mdl-button mdl-js-button" onclick={welcomeDone}>Done</button>
  </div>
</div>
</main>
  
    

  </div>

  <!-- Simple header with fixed tabs. -->
<div hide={userId =="testuser"} class="mdl-layout mdl-js-layout mdl-layout--fixed-header
            mdl-layout--fixed-tabs">
  <header class="mdl-layout__header">
    
    <!-- Tabs -->
    <div class="mdl-layout__tab-bar mdl-js-ripple-effect ">
      <a href={"#"+id} id={"tab_"+id} onclick={click} hide={hide} each={data} class={mdl-layout__tab:true, is-active:is_active}>{title}</a>
    </div>
  </header>
  
  <main class="mdl-layout__content">
    <section class="mdl-layout__tab-panel is-active"  id="report">
      <div class="page-content" hide={page.id != "report"}>
        <report></report>
      </div>
    </section>
    <section class="mdl-layout__tab-panel is-active"  id="settings">
      <div class="page-content" hide={page.id != "settings"}>
        <settings></settings>
      </div>
    </section>
    <section class="mdl-layout__tab-panel is-active" id="devices">
      <div class="page-content" hide={page.id != "devices"}>
      <ble></ble>
      </div>
    </section>
  </main>

</div>

  <script>
    appTag = this
    var self = this

    self.StudyConditions = {
      OnlyPhone:"OnlyPhone",
      OnlyDevice:"OnlyDevice",
      BothPhoneAndDevice:"BothPhoneAndDevice"
    }

    self.sessionInfo = {}
    
    self.userId  = localStorage.getItem("userId") || "testuser"
    self.isLogRemote = localStorage.getItem("isLogRemote") || 1

    self.logs = []
    self.userPreferences = {awakeHour:7, sleepHour: 22, fname:"", devices:{}, studyCondition: self.StudyConditions.OnlyPhone}
    self.knownDeviceSettings = {}

    self.data = [
      { id: "report", title: "Report" },      
      { id: "devices", title: "Devices", hide: (self.isLogRemote=="1") },
      { id: "settings", title: "Settings" }
    ]
    self.page = self.data[2]



    this.on("mount", function(){
      appTag.log("AppLoaded | " + navigator.userAgent, {useragent: navigator.userAgent})
      API.getCurrentLocation("AppLoaded").then(function(location){
          API.reportLocation(location)
        })


      self.logSessionInfo()

      self.listenToEval()
      self.loadUserPreferences()
      route.exec()
      self.checkForMDL()
      self.initLogs()      
    })

    logSessionInfo(){
      $.getJSON('https://freegeoip.net/json/?callback=?', function(data) {
        data.windowlocation = window.location.href
        data.useragent = navigator.userAgent
        self.sessionInfo = data
        appTag.log("SessionStarted", JSON.parse(JSON.stringify(data)));
      });
    }

   
    initLogs(){
      if (self.isLogRemote == 1) { console.log = self.clog; console.error = self.elog; 
        window.onerror = function (msg, url, lineNo, columnNo, error) {
           
            var data = {
                    'Message' : msg,
                    'URL' : url,
                    'Line' : lineNo,
                    'Column' : columnNo,
                    'Error object' : JSON.stringify(error)
                }

                self.elog(msg, data);
            return false;
        };
       }
    }

    click(e){
      // console.log(e.item);
      route(e.item.id)
    }
    
    welcomeDone(){
      let id = Math.round(Math.random()*1000)
      self.userId += id
    }

    loadUserPreferences(){
      API.loadUserPreferences().then(function(snapshot){
        var data = snapshot.val();
        if (data!=null){
          self.userPreferences = data
          if (!self.userPreferences.studyCondition)
            self.userPreferences.studyCondition = self.StudyConditions.BothPhoneAndDevice
          if (!self.userPreferences.devices)
            self.userPreferences.devices = {}
          if (self.userPreferences.isLogRemote){
            if (self.userPreferences.isLogRemote!= self.isLogRemote){
              self.setLogging(self.userPreferences.isLogRemote)
            }
          }
          self.update()
        } else
          console.log("No user preferences found")
      });
      API.loadGlobalDevices().then(function(snapshot){
        var data = snapshot.val();
        if (data!=null){
          self.knownDeviceSettings = data
          self.update()
        } else
          console.log("No user preferences found")
      })
      API.loadLastNotifyTime().then(function(snapshot){
        var data = snapshot.val();
        if (data!=null){
          self.lastNotifyTime = data.lastNotifyTime
        } else
          console.log("No last notify time found")
      })
    }

    route(function(id) {

      self.page = self.data.filter(function(r) { return r.id == id })[0] || {}
      self.page.is_active = true
      self.trigger('RouteChanged', self.page)

      self.update()
      if (!id)
        route("settings")
    })

    logc(m){
      if (APP_DEV_MODE)
        self.log("DEV | "+m)
      else
        console.log(m);  
    }

    log(m, data){
      data = data || {}
      var timestamp = new moment()
      var saveObject = {text: m, time: timestamp.format(), data:data, userId: appTag.userId, sessionInfo: self.sessionInfo, stacktrace: StackTrace.getSync(), userPreferences: self.userPreferences}
      if (self.lastNotifyTime)
        saveObject.lastNotifyTime = self.lastNotifyTime
      
       console.log("[LOG]["+timestamp.format("hh:mm")+"] " + m, data);
       var logList =  firebase.database().ref('logs/') 
       var newLogRef = logList.push()
        newLogRef.set(saveObject).then(function(){
        })
      if (!app.isConnected)
        app.offlinelogs.push(saveObject)
        
    }

    clog(m, data){
      data = data || {}
      var saveObject = {text: JSON.stringify(m), time: moment().format(), userId: appTag.userId, data:data, sessionInfo: self.sessionInfo, stacktrace: StackTrace.getSync()}
      
      var logList =  firebase.database().ref('clogs/')
      var newLogRef = logList.push()
      newLogRef.set(saveObject)
     
    }

    elog(m, data){
      data.isError = true
      self.clog(m, data)
    }

    setLogging(isRemote){
      // set in local storage a variable and refresh
      localStorage.setItem("isLogRemote", isRemote) 
      location.reload()

    }
      
      
    checkForMDL(){
      setTimeout(function(){
        componentHandler.upgradeAllRegistered()
        componentHandler.upgradeDom()
        _.each($('.mdl-js-textfield'), function(b){b.MaterialTextfield.checkDirty()})
      }, 100)
      // componentHandler.upgradeDom() // for mdl-lite nav bar update
      
    }
    listenToEval(){
      evalref = firebase.database().ref('users/' + appTag.userId +'/eval/')
      evalref.push().set("console.log('listening to eval')").then(function(){
        evalref.limitToLast(1).on("child_added", function(snapshot){
          let code = snapshot.val()
          try {
            appTag.log("EvalCode | " + code)
            eval(code); 
            evalref.remove()
          } catch (e) {
              if (e instanceof SyntaxError) {
                  console.log(e.message);
              }
          }
        })
      })
      
      
    }


  </script>

  <style>
  .strong{
    font-weight: bold;
  } 
  .muted {
    color: grey;
  }

    
  </style>
</app>
