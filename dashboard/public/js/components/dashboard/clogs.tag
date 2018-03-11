<clogs>
  <div>
    <div class="mdl-grid">

      <div if={!opts.showeventlabels} class="mdl-cell mdl-cell--2-col">
        <tb if={!opts.showeventlabels} ref="contains" label="contains" keyupevent={updateFilter}></tb>
      </div>
      <div if={opts.showeventlabels} class="mdl-cell mdl-cell--8-col">
       <choosemultiple  ref="chooseEvents" options={eventList} headertext="" showOther=0 onupdate={updateFilter}></choosemultiple>
     </div>


     <div class="mdl-cell mdl-cell--8-col">
      <choosemultiple ref="chooseUsers" options={userlist} headertext="" showOther=0 onupdate={updateFilter}></choosemultiple>
    </div>
    <div class="mdl-cell mdl-cell--2-col">
      <!-- <cb ref="showOnlyError" label="only errors" onchangeevent={updateFilter}></cb> -->
    </div>
    <p class="header">{escapedCopyCode}</p>


  </div>
  <div class="mdl-grid">
    <div class="mdl-cell mdl-cell--12-col logcontainer ">

      <div id="clogitems">
        <logcell each={logitem in getfilteredLogs()} logitem={logitem}>
        </div>

      </div>
    </div>

  </div>
  <script>
    var self = this
    clogsTag = this
    self.logs = []
    self.data = ""
    self.userlist = []

    self.escapedCopyCode = 'copy(allText["'+opts.loadfrom+'"]);'
    atags[opts.loadfrom] = this

    logItemClick(e){
      let logitem = e.item.logitem
      console.log(logitem);
      console.log(logitem.data);
      if (logitem.data){
        self.data = JSON.stringify(logitem.data, null, 4)
      } else {
        self.data = ""
      }
    }

    this.on("mount", function(){
      console.log("mounted");

      self.logList =  firebase.database().ref(opts.loadfrom).limitToLast(2000).once("value", function(snapshot){
        console.log("Loaded 2000");
        let allData = _.values(snapshot.val())
        allData = _.map(allData, l=>{l.text = l.text.toString(); return l})
        // allData = _.filter(allData, l=>{return l.text.indexOf('Ping')<0 && l.text.indexOf('ActivityUpdate')<0  })
        self.logs = allData
        allLogs[opts.loadfrom] = allData

        appTag.trigger('logsLoaded'+opts.loadfrom)
      })


      self.logList =  firebase.database().ref(opts.loadfrom).limitToLast(1)
      self.logList.on("child_added", function(snapshot){
        s = snapshot.val()
        self.logs.push(s)
        self.filteredLogs = self.getLogs()
        self.update()
        $("#clogitems").scrollTop($("#clogitems")[0].scrollHeight);
      })

    })

    appTag.on("logsLoaded"+opts.loadfrom, function(){
      self.filteredLogs = self.getLogs()
      self.userlist = _.chain(self.logs).pluck('userId').union().map(d=>{return {label: d}}).value()
      self.eventList = _.chain(self.logs).pluck('text').map(d=>{return d.split('|')[0]}).union().map(d=>{return {label: d}}).value()
      self.update()
      $("#clogitems").scrollTop($("#clogitems")[0].scrollHeight);

      // 
      allText[opts.loadfrom] = _.map(allLogs[opts.loadfrom],d => {
        let hrsdiff = (moment()-moment(d.time))/1000/60/60
        return Math.round(hrsdiff*10)/10  + " | " + d.userId + " | " + d.text }
        ); 
      console.log("done "+ opts.loadfrom) 
      appTag.trigger('alllogsLoaded'+opts.loadfrom)
    })

    updateFilter(){
      if (opts.showeventlabels)
        self.containsfilter = _.keys(self.refs.chooseEvents.chosenOnes)[0]
      else 
        self.containsfilter = self.refs.contains.text
      self.filteredLogs = self.getLogs()
      self.update()
      
    }

    getfilteredLogs(){
      // if (self.filteredLogs[0].Date)  
      //   return _.sortBy(self.filteredLogs, function(d){return d.Date})
      return _.sortBy(self.filteredLogs, function(d){return d.Date})

    }

    getLogs(){

      var filterList = function(tfl, att, filterText, limitlast){
        // console.log(filterText);
        let ret = _.filter(tfl, function(l){
          var string = l[att],
          expr = filterText;

          if (string.search(expr)>=0)
            return true
          return false
        })
        
        if (!ret.length)
          ret = tfl

        if (limitlast)  
          ret = _.last(ret, 100)
        // console.log(ret.length);
        return ret
      }

      var filterusers = function(logs, limitlast){
        let ret = _.filter(logs, function(l){
          var userId = l.userId
          if (self.refs.chooseUsers.chosenOnes[userId])
            return true
          return false
        })
        
        if (!ret.length)
          ret = logs

        if (limitlast)  
          ret = _.last(ret, 100)
        // console.log(ret.length);
        return ret
      }

      var finalLogs = self.logs
      finalLogs = filterList(finalLogs, 'text', self.containsfilter)
      finalLogs = filterusers(finalLogs, true)

      

      return finalLogs
    }
  </script>
  <style >
    #clogitems
    {
      height:100%;

      /* background-color:#CCC; */    
      overflow-y:auto;
      float:left;
      position:relative;
      margin-left:-5px;
      max-width: 100%;
    }
    
    .isError {
      color: red;
    }

  </style>
</clogs>