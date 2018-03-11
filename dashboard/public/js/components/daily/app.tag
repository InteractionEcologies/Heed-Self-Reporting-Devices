<app>
  <!-- Simple header with fixed tabs. -->
<div class="mdl-layout mdl-js-layout mdl-layout--fixed-header
            mdl-layout--fixed-tabs">
  <header class="mdl-layout__header">
    
    <!-- Tabs -->
    <div class="mdl-layout__tab-bar mdl-js-ripple-effect ">
      <a href={"#"+id} onclick={click} each={data} class={mdl-layout__tab:true, is-active:is_active}>{title}</a>
    </div>
  </header>
  
  <main class="mdl-layout__content">
    <section class="mdl-layout__tab-panel is-active"  id="diary">
      <div class="page-content" hide={page.id != "diary"}>
        <diary userId={userId}></diary>
      </div>
    </section>
  </main> 
  It takes a few seconds to load ...

</div>

  <script>
    appTag = this
    var self = this
    self.data = [
      { id: "diary", title: "HEED Diary" }]
    self.page = self.data[0]
    self.onlyview = false


    this.on("mount", function(){
      route.exec()
      window.onbeforeunload = function () {
          appTag.log("Exit")
      };
    })

    click(e){
      // console.log(e.item);
      route(e.item.id)
    }
    
  

    route(function(id) {
      self.page = self.data.filter(function(r) { return r.id == id })[0] || {}
      self.page.is_active = true
      self.trigger('RouteChanged', self.page)
      
      self.update()
      if (!id)
        route("diary")
    })

    route('/diary/*', function(name) {
      self.userId = name
      self.logSessionInfo()
      self.tags.diary.updateDiary()
      self.update()
    })

    route('/onlyview/*', function(name) {
      console.log("only view mode");
      self.userId = name
      self.tags.diary.updateDiary()
      self.onlyview = true
      self.update()
    })

    logSessionInfo(){
      $.getJSON('https://freegeoip.net/json/?callback=?', function(data) {
        data.windowlocation = window.location.href;
        appTag.log("Opened", JSON.parse(JSON.stringify(data)));
      });
    }
    
    log(m, data){
      data = data || {}
      var timestamp = new moment()
      var saveObject = {text: "DIARY | "+m, time: timestamp.format(), data:data, userId: appTag.userId}
      console.log("[DIARY-LOG]["+timestamp.format("hh:mm")+"] " + m);
      if (!self.onlyview)
        firebase.database().ref('logs/').push().set(saveObject)
    }
    
    checkForMDL(){
      setTimeout(function(){
        componentHandler.upgradeAllRegistered()
        componentHandler.upgradeDom()
        _.each($('.mdl-js-textfield'), function(b){b.MaterialTextfield.checkDirty()})
      }, 100)
      // componentHandler.upgradeDom() // for mdl-lite nav bar update
      
    }


  </script>

  <style>
  .strong{
    font-weight: bold;
  } 

  .mdl-layout__tab-bar {
    height: 48px;
  }
  .header{
    color: grey;
    font-size: 8pt;
    margin: 0px;
  }
  .text{

  }
  .logcontainer{
    height: 80vh;
    float:left;
    padding:0 0 0 5px;
    position:relative;
    float:left;
    border-right: 1px #f8f7f3 solid;
    /* background-color: black; */
  }
  </style>
  
</app>
