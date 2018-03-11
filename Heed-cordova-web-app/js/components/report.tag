<report>
<div if={appTag.userPreferences.studyCondition == "OnlyDevice"}>
<div class="mdl-grid centered">
  <p>
    This feature will be available during the first and last stage of the study. 

    Study team will let you know. Thanks.

    <p>Some tips:
        <ul><li>Devices can be stuck on the wall with the stickers provided</li>
        <li>Feel free to self-initiate reports when you like it</li>
        </ul>
        </p>

  </p>
</div>

</div>
<div if={appTag.userPreferences.studyCondition != "OnlyDevice"}>
  <div if={!loaded}>
    Loading...
  </div>
    <div if={loaded && minutesSinceLastReport>=10} class="activityTypes">
      <div id="duration">
        <span >
          It's {getDuration()}
        </span>      
      </div>
      <div class="chooseOneContainer">
        <chooseone ref="previousLocations" type="Location" headertext="Where were you? (e.g. Home Kitchen)" options={previousActivityLocations}></chooseone>
        <chooseone ref="previousActivities" showOther=0  type="Activity" headertext="What were you doing a few minutes ago?" options={previousActivityLabels}></chooseone>
        <chooseone ref="withPeople" showOther=0 headertext="3) Are you with other people?" options={ withPeopleOptions }></chooseone>
        <div id="doneButton">
           <button disabled={doneDisabled()}  class="mdl-button mdl-js-button  mdl-button--colored" onclick={done}>
            Done
        </button>
        </div>
        
      </div>
      
    </div>
    <div class="centered" if={loaded && minutesSinceLastReport<10}>
      <div>
      <h3>Thanks {parent.userId}!</h3>
      <p>
        You reported {Math.round(minutesSinceLastReport,2)} minutes ago. Please come back again later.
      </p> 

      <p if={Offline.state == "down"}>
        You are currently Offline. Your report may not be saved if it doesn't show below. Please connect to internet to sync.
      </p>
      </div>
      <h4>Your reports from phone</h4>
      <table class="mdl-data-table mdl-js-data-table mdl-shadow--2dp">
        <thead>
          <tr>
            <th width="20px" class="mdl-data-table__cell--non-numeric">Time</th>
            <th class="mdl-data-table__cell--non-numeric">Act</th>
            <th class="mdl-data-table__cell--non-numeric">Place</th>
            <th  class="mdl-data-table__cell--non-numeric">People</th>

          </tr>
        </thead>
        <tbody>
          <tr each={previousActivityReports} onclick={edit}>
            <td class="mdl-data-table__cell--non-numeric">{moment(new Date(createTime)).fromNow().replace("minutes", "mins")}</td>
            <td class="mdl-data-table__cell--non-numeric">{activity}</td>
            <td class="mdl-data-table__cell--non-numeric"><span class="tabletext">{location.slice(0,8)}</span></td>
            <td class="mdl-data-table__cell--non-numeric">{withPeople}</td>
          </tr>
        </tbody>
      </table>
    </div>
</div>

  
  <script>
   var self = this
   reportTag = self
   self.loaded = false

   doneDisabled(){  
    if (self.refs.previousActivities.chosenOne.label && self.refs.previousLocations.chosenOne.label && self.refs.withPeople.chosenOne.label )
      return false
    return true
   }

   this.activityTypes = []
   self.initActivityTypes = [{activity: "Eat", location:"home", withPeople:"Yes"}]
   // self.activityColors = ["#7CB342",  "#F4511E", "#00ACC1", "#00897B", "#FDD835", "#1E88E5", "#e53935", "#D81B60", "#5E35B1", "#FFB300", "#3949AB", "#8E24AA", "#6D4C41", "#039BE5", "#C0CA33", "#43A047", "#FB8C00","#ccc" ]
   self.previousActivityInitLabels = [
     {label: "Work"},
     {label: "Transport"},
     {label: "Exercise"},
     {label: "Entertainment"},
     {label: "Social"},
     {label: "Food"},
     {label: "Personal Care"},
     {label: "Shop, Errands"},
     {label: "Household"},
     {label: "Sleep"},
     {label: "Other"}
   ]
   self.previousActivityLabels = self.previousActivityInitLabels
   self.previousActivityLocations = []
   self.withPeopleOptions = [{label:"Yes"}, {label:"No"}]
   self.comment = ""
   
   self.minutesSinceLastReport = 100

   this.on("mount", function(){
      // self.init()
    })

   appTag.on("RouteChanged", function(page){
    if(page.id=='report')
      self.initPreviousActivityTypes()
      self.init()
   })
   
   init(){
    self.showDOM()
    // self.initPreviousActivityTypes()
    self.update()
    clearInterval(self.timer)
    self.timer = setInterval(function(){
      if (self.lastReportedActivity)
        $.get("http://gauravparuthi.com/images/favicon.ico")
        Offline.check()
        self.minutesSinceLastReport = (new Date() - new Date(self.lastReportedActivity.createTime))/1000/60
      self.update()
    },10000)
   }

    initPreviousActivityTypes(){
      API.fetchUserData('activities', function(allActivities){
        // console.log(allActivities);
        var previousActivityReports = _.values(allActivities)
        self.lastReportedActivity = previousActivityReports[previousActivityReports.length-1]
        self.minutesSinceLastReport = (new Date() - new Date(self.lastReportedActivity.createTime))/1000/60
        // self.previousActivityLabels = _.map(_.uniq(previousActivityReports, function(a){return a.activity}), function(a){  return {label: a.activity} })
        self.previousActivityLocations = _.map(_.uniq(previousActivityReports, function(a){return a.location}), function(a){return {label: a.location}})
        self.previousActivityReports = previousActivityReports.reverse()
        self.showDOM()
      }, function(){
        // console.log("No previous data found for the selected date.");
        // self.previousActivityLabels = []
        self.previousActivityLocations = []
        self.showDOM()
      })

    }
    showDOM(){
      self.loaded = true
      componentHandler.upgradeDom()
      self.update()
    }


   getDuration(){
        self.curTime = new Date()

        return moment(self.curTime).format('LT')
      }

    done(){
      self.minutesSinceLastReport = 0
      self.reportActivity()
      self.update()
    }

    updateComment(e){
      self.comment = e.target.value;
    }



    reportActivity(){
      var timestamp = new Date()
      self.reportToStore = {
            activity: self.refs.previousActivities.chosenOne.label, 
            location: self.refs.previousLocations.chosenOne.label, 
            withPeople: self.refs.withPeople.chosenOne.label, 
            comments: self.comment,
            time: self.curTime.toString(), 
            createTime: timestamp.toString(),
            fromDevice: "Phone",
            userPreferences: appTag.userPreferences           
          }
      console.log("Going to store activity report", self.reportToStore);
      self.lastReportedActivity = self.reportToStore

      function reportActivity(location){
        if (location)
          self.reportToStore['gps_location'] = location
        
          API.reportActivity(self.reportToStore).then(function(ref){
            appTag.log('OnActivityReportActivity | ', self.reportToStore)
            self.initPreviousActivityTypes()
            self.init()            
          }, function(error){
            appTag.log('Error | ' + JSON.stringify(error))
          })
      }
      API.getCurrentLocation("OnReport")
      reportActivity() 
      


    }

    edit(e){
      console.log('here');
      console.log(e.item);
      self.update()      
    }

  
  </script>
  <style scoped>
  .centered{
    text-align: center;
  }
  #duration{
    font-family: 'HelveticaNeue-Light', 'Helvetica Neue Light', 'Helvetica Neue', Helvetica, Arial, 'Lucida Grande', sans-serif;
    font-size: 30px;
    text-align: center;
    margin: 1em;
  }
  .activityTypes{
    /*text-align: center;*/
  }
   #doneButton button{
    font-size: 20px;
   }
   .tabletext{
    text-overflow: ellipsis;
    width: 150px;
   }
   .mdl-data-table{
    margin: 0px auto;
   }
   .chooseOneContainer{
     margin: 1em;
   }
  </style>
</report>
