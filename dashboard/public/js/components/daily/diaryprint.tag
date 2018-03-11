<diary>
<div>
	<div each={day in getDays()} class="mdl-grid mdl-card mdl-shadow--2dp day">
			<div class="mdl-cell mdl-cell--12-col">
			  <h4>{day.date}</h4>

			  <reportcell reportitem={item} each={item in getReportItems(day.date)} ></reportcell>

			</div>

	  	  


	    
	    <div class="mdl-cell mdl-cell--12-col">
	      <p>{day.overallComment}</p>
	      <p>{day.researcherComment}</p>
	    </div>
	  </div>
	</div>
	
</div>

<script>
	var self= this
	diaryTag = this
	self.reportItems = []
	self.selectedReportItem = undefined

	self.days = []

	this.on("mount", ()=>{


	})

	getDays(){
		return _.sortBy(self.days, function(d){return moment(d.timestamp)})//.reverse()
	}
	updateDiary(){
		self.days = []
		self.userId = self.parent.userId
		self.selectedReportItem = undefined
		self.fetchUserData()
		appTag.onlyview = false
	}

	getReportItems(date){
		return _.chain(self.reportItems).filter(r=>{return r.daydate=== date}).sortBy(function(d){return new Date(d.createTime)}).value()
	}

	fetchUserData(){
		var ref = firebase.database().ref('users/' + appTag.userId)
		ref.once("value", s => {
			d = s.val()
			// console.log(d);

			// load already existing reports
			if (!d.finalreports2)
				d.finalreports2 = d.finalreports
			self.reportItems = _.values(d.finalreports2)

			// push any reports from phone
			// console.log('Here');
			
			var phoneReports = _.chain(d.activities).values().union().map(r=>{
					r.deviceType = "Phone"
					r.uniqueHash = moment(r.time).format() + '-phone' 
					return r
				}).value()

			for (var i in phoneReports){
				rid = phoneReports[i].uniqueHash
				// console.log(rid);
				if (!_.find(self.reportItems, r=>{return r.uniqueHash===rid})){
					// console.log('Pushing phone report');
					self.reportItems.push(phoneReports[i])
				}
			}

			// push device reports
			var deviceReports = _.values(d.deviceReports)
			deviceReports = helpers.getDeviceReports(deviceReports)
			for (var i in deviceReports){
				dr = deviceReports[i]
				rid = dr.uniqueHash
				// console.log(dr.activity);

				var oldReport = _.find(self.reportItems, r=>{return r.uniqueHash===rid})
				if (!oldReport){
					// console.log('Pushing device report to final reports', dr);
					self.reportItems.push(dr)
				} else {
					// console.log(moment(oldReport.time).format("LT"), oldReport.activity);
					if (!oldReport.activity)
						oldReport.activity = []
					oldReport.activity = oldReport.activity.concat(dr.activity)
					oldReport.deviceReports = oldReport.deviceReports.concat(dr.deviceReports)
					// console.log(oldReport.activity);
				}

			}
			

			self.index = 0;
			_.each(self.reportItems, r=>{
				r.daydate = moment(r.createTime).format("MMM Do")
				r.index = self.index++
				var existingDay = _.find(self.days, d=>{
					if (d.date === r.daydate) return true })
				if (!existingDay)
					self.days.push({date: r.daydate, timestamp: r.createTime, overallComment: helpers.fetchOverallComments(r.daydate, d),researcherComment: helpers.fetchResearcherComments(r.daydate, d)})
				
			})
			self.reportItems = _.map(self.reportItems, r=>{if( typeof r.activity != 'string' ) r.activity= _.union(r.activity); return r; })

			self.update()
		})
	}
	save(){

			let refstr = 'users/' + appTag.userId + '/finalreports2/'
			
			updates = {}

			_.each(self.reportItems, function(rec){
		      	updates[refstr + rec.uniqueHash] = rec
		      })

			console.log("saving", JSON.stringify(updates));

		      firebase.database().ref().update(updates).then(function(){
		      	console.log('Saved to firebase data ');
		      })
		      self.update()

	}



</script>

<style scoped>
	.day{
		width: 100%;
		border: 4px;
	}
	.tablecolumn{
		max-width: 200px;
		overflow: hidden;
    	text-overflow: ellipsis;
    	white-space: nowrap;
	}
	.isWrong {
		color: red
	}
	.isRight {
		color: green
	}

</style>
	

</diary>