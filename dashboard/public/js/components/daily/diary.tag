<diary>
<div>
	<div each={day in getDays()} class="mdl-grid mdl-card mdl-shadow--2dp day">
			<div class="mdl-cell mdl-cell--12-col">
			  <h2>{day.date}</h2>
			</div>
	
	  
	  <div class="mdl-card mdl-shadow--2dp mdl-cell mdl-cell--8-col">
	  <table class="mdl-data-table mdl-js-data-table mdl-shadow--2dp">
	    <thead>
	      <tr>
	        <th  class="mdl-data-table__cell--non-numeric">Time</th>
	        <th class="mdl-data-table__cell--non-numeric tablecolumn">Activity</th>
	        <th class="mdl-data-table__cell--non-numeric tablecolumn">Place</th>
	        <th  class="mdl-data-table__cell--non-numeric">People</th>
	        <th  class="mdl-data-table__cell--non-numeric">Device</th>
	        <th  class="mdl-data-table__cell--non-numeric"><i class="material-icons">done</i></th>


	      </tr>
	    </thead>
	    <tbody>
	      <tr each={getReportItems(day.date)} onclick={reportItemClick}>
	        <td class="mdl-data-table__cell--non-numeric">{moment(time).format("LT")}</td>
	        <td class="mdl-data-table__cell--non-numeric tablecolumn">{_.union([].concat(activity))}</td>
	        <td class="mdl-data-table__cell--non-numeric tablecolumn"><span class="tabletext">{location}</span></td>
	        <td class="mdl-data-table__cell--non-numeric">{withPeople}</td>
	        <td class="mdl-data-table__cell--non-numeric">{deviceType}</td>
	        <td class="mdl-data-table__cell--non-numeric"><span class={isWrong: (isVerified=="Its Wrong"), isRight: (isVerified=="Looks Good")}><i if={done} class="material-icons">done</i></span></td>
	      </tr>
	    </tbody>
	  </table>

	    
	    <div class="mdl-cell mdl-cell--12-col">
	      <h4>Overall comments for the day</h4>
	      <p class="header">Did we miss anything?</p>
	      <p class="header">What were your overall comments about using phone or the device?</p>
	      <tb label="Comments" changeevent={save} ref={day.date+"Comment"} textvalue={day.overallComment}></tb>
	      <mtb if={appTag.onlyview} label="ResearcherComments" changeevent={saveresearchercomment} ref={day.date+"ResearcherComment"} textvalue={day.researcherComment}></mtb>
	    </div>
	  </div>
	  <div class="mdl-card mdl-shadow--2dp mdl-cell mdl-cell--4-col">
	    <activityquestions ref={"aq"+day.date}></activityquestions>
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
		return _.sortBy(self.days, function(d){return moment(d.timestamp)}).reverse()
	}
	updateDiary(){
		self.userId = self.parent.userId
		self.days = []
		self.selectedReportItem = undefined
		self.fetchUserData()
	}

	getReportItems(date){
		return _.chain(self.reportItems).filter(r=>{return r.daydate=== date}).sortBy(function(d){return new Date(d.createTime)}).value()
	}

	fetchUserData(){
		var ref = firebase.database().ref('users/' + appTag.userId)
		ref.once("value", s => {
			d = s.val()
			console.log(d);

			// load already existing reports
			self.reportItems = _.values(d.finalreports)

			// push any reports from phone
			
			var phoneReports = _.chain(d.activities).values().union().map(r=>{
					r.deviceType = "Phone"
					r.uniqueHash = moment(r.time).format() + '-phone' 
					return r
				}).value()

			for (var i in phoneReports){
				rid = phoneReports[i].uniqueHash
				if (!_.find(self.reportItems, r=>{return r.uniqueHash===rid})){
					self.reportItems.push(phoneReports[i])
				}
			}

			// push device reports
			var deviceReports = _.values(d.deviceReports)
			deviceReports = helpers.getDeviceReports(deviceReports)
			for (var i in deviceReports){
				dr = deviceReports[i]
				rid = dr.uniqueHash
				console.log(dr.activity);

				var oldReport = _.find(self.reportItems, r=>{return r.uniqueHash===rid})
				if (!oldReport){
					console.log('Pushing device report to final reports', dr);
					self.reportItems.push(dr)
				} else {
					console.log(oldReport);
					oldReport.activity = dr.activity
					oldReport.deviceReports = oldReport.deviceReports
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




	reportItemClick(e){
		console.log(e.item)
		var reportItem  = e.item
		self.selectedReportItem = reportItem
		self.showSelectedReportDiary()
	}

	showSelectedReportDiary(){
		let tagref  = "aq" + self.selectedReportItem.daydate
		self.refs[tagref].updateReportItem(self.selectedReportItem)
	}

	next(){
		let curIndex = self.selectedReportItem.index
		
		self.selectedReportItem = _.find(self.reportItems, r=>{return r.index===(curIndex+1)})
		if (!self.selectedReportItem)
			self.selectedReportItem = self.reportItems[0]
		self.showSelectedReportDiary()
		// self.save()

		self.update()
	}

	save(){

		if (!appTag.onlyview){
			let refstr = 'users/' + appTag.userId + '/finalreports/'
			let dayrefstr = 'users/' + appTag.userId + '/days/'

			updates = {}

			_.each(self.days, d=>{
				updates[dayrefstr+ d.date + "/comment"] = self.refs[d.date+"Comment"].text
			})

			_.each(self.reportItems, function(rec){
		      	updates[refstr + rec.uniqueHash] = rec
		      })

			appTag.log("saved", JSON.stringify(updates));

		      firebase.database().ref().update(JSON.parse(JSON.stringify(updates))).then(function(){
		      	console.log('Saved to firebase data ');
		      })
		      self.update()
		}
	}

		saveresearchercomment(){
			let dayrefstr = 'users/' + appTag.userId + '/days/'
			updates = {}
			_.each(self.days, d=>{
				updates[dayrefstr+ d.date + "/researcherComment"] = self.refs[d.date+"ResearcherComment"].text
			})
			console.log("researcher comment saved", JSON.stringify(updates));

		      firebase.database().ref().update(JSON.parse(JSON.stringify(updates))).then(function(){
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