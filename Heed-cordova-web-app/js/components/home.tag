<home > 
  <h4 onclick={showReportsToggle}>Device Reports</h4>
  <ul if={showReports} class='mdl-list'>
    <button class="mdl-button mdl-js-button  mdl-button--colored" onclick={refresh}>
        Refresh
     </button>

    <li class="mdl-list__item mdl-list__item--two-line" each={allRecords.slice(0,10)}>
      <span class="mdl-list__item-primary-content">
            <i class="material-icons mdl-list__item-avatar">person</i>
            <!-- <span>{getValue(value)} ({value}/100)</span> -->
            <span class="mdl-list__item-sub-title">{moment(new Date(time)).calendar()}</span>
          </span>
          <a class="mdl-list__item-secondary-action" href="#"><i class="material-icons">delete</i></a>
    </li>
  </ul>

  <script>
  homeTag = this
    var self= this
    transactions = []
    uniqueDevices = {}
    self.showReports = false

    self.allRecords = [
    ]

    showReportsToggle(){
      self.showReports = !self.showReports
    }

    // getValue(v){
    //   function map_range(value, low1, high1, low2, high2) {
    //       return low2 + (high2 - low2) * (value - low1) / (high1 - low1);
    //   }
    //   return Math.round(map_range(v, 0,100,1,5))
    // }

    this.on("mount", function(){
      self.refresh()
    })
    
    refresh(){
      console.log("Reading users history from fb");
      // read from firebase
       var thisDeviceListRef =  firebase.database().ref('users/' + appTag.userId + '/allrecords')

       thisDeviceListRef.once("value", function(snapshot) {
        var alltransactions = snapshot.val()
        uniqueDevices = {}

        // console.log(alltransactions);
        for (let transactionkey in alltransactions){
          let transaction = alltransactions[transactionkey]
          // console.log(transaction);
          transactions.push(transaction)
          var device = transaction.device
          if (!(device.address in uniqueDevices)){
            uniqueDevices[device.address] = device
          }
          else{
            var d = uniqueDevices[device.address]
            if (moment(d.createTime)<moment(transaction.createTime))
            {
              uniqueDevices[device.address] = d             
            }              
          }

          // console.log(transaction);
          var newrecs = transaction.records
          allRecords = self.allRecords = _.union(self.allRecords, newrecs)
          
        } 
        // uniqueDevices = _.chain(transactions).pluck('device').uniq(function(d){return d.address}).value()
        self.allRecords = _.uniq(self.allRecords, function(x){
              return x.uniqueHash;
          });
        self.allRecords = _.sortBy(self.allRecords, function(d){return new Date(d.time)})
        self.allRecords.reverse()
        records = self.allRecords

        self.update()
        appTag.update()

      });
    }

    delete(){
      // TODO add code to move the record in allrecords to deleted records
    }

  </script>
  
</home>