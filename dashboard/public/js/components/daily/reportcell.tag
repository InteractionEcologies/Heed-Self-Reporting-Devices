<reportcell>
	<div class="mdl-grid" onclick={click}>
	  <div class="mdl-cell mdl-cell--1-col header">{moment(reportItem.time).format("LT")}</div>
	  <div class="mdl-cell mdl-cell--2-col text">
		  <div class="mdl-cell mdl-cell--12-col header">Activity</div>
		  <div class="mdl-cell mdl-cell--12-col text">{reportItem.activity}</div>
	  </div>
	  <div class="mdl-cell mdl-cell--2-col text">
		  <div class="mdl-cell mdl-cell--12-col header">Location</div>
		  <div class="mdl-cell mdl-cell--12-col text">{reportItem.location}</div>
	  </div>
	  <div class="mdl-cell mdl-cell--1-col text">
		  <div class="mdl-cell mdl-cell--12-col header">With People?</div>
		  <div class="mdl-cell mdl-cell--12-col text">{reportItem.withPeople}</div>
	  </div>
	  <div class="mdl-cell mdl-cell--1-col text">
		  <div class="mdl-cell mdl-cell--12-col header">Device</div>
		  <div class="mdl-cell mdl-cell--12-col text">{reportItem.deviceType}</div>
	  </div>
	  <div class="mdl-cell mdl-cell--1-col text">
		  <div if={reportItem.done} class="mdl-cell mdl-cell--12-col text"><span class={isWrong: (reportItem.isVerified=="Its Wrong"), isRight: (reportItem.isVerified=="Looks Good")}><i if={reportItem.done} class="material-icons" onclick={doneclick}>done</i></span></div>
	  </div>
	  <div class="mdl-cell mdl-cell--1-col text" if={!showscChoice()}>
		  <div class="mdl-cell mdl-cell--12-col header">SC</div>
		  <div class="mdl-cell mdl-cell--12-col text">{reportItem.userPreferences.studyCondition}</div>
	  </div>
	  <div class="mdl-cell mdl-cell--4-col text" if={showscChoice()}>
		  <div class="mdl-cell mdl-cell--12-col header">SCO</div>
		  <chooseone options={studyConditionOptions} onlabelclick={changeStudyCondition}></chooseone>
	  </div>
	   <div class="mdl-cell mdl-cell--12-col text">
	   <div class="mdl-cell mdl-cell--12-col header" if={reportItem.comment}>Comment</div>
		  <p if={reportItem.comment}>{reportItem.comment}</p>
	  </div>
	  <div class="mdl-cell mdl-cell--12-col text">
	   <div class="mdl-cell mdl-cell--12-col header" if={reportItem.whatsWrong}>Whats wrong</div>
		  <p if={reportItem.whatsWrong}>{reportItem.whatsWrong}</p>
	  </div>
	  
	  
	</div>
	<script>
	var self = this
	self.reportItem = opts.reportitem

	self.studyConditionOptions = [{label:"OnlyPhone"},{label:"OnlyDevice"},{label:"BothPhoneAndDevice"}]

	isSelected(){
		if (diaryTag.selectedReportItem)
		return self.reportItem.uniqueHash == diaryTag.selectedReportItem.uniqueHash
	}

	removeFromFirebase(){
		// var ref = firebase.database().ref('users/' + appTag.userId + '/finalreports/' + self.reportItem.uniqueHash)
	 //    adaRef.remove()
	 //      .then(function() {
	 //        console.log("Remove succeeded.")
	 //      })
	 //      .catch(function(error) {
	 //        console.log("Remove failed: " + error.message)
	 //      });
	}
	click(){
		console.log(self.reportItem);
	}
	changeStudyCondition(chosenOne){
		if (!self.reportItem.userPreferences)
			self.reportItem.userPreferences = {}
		self.reportItem.userPreferences.studyCondition = chosenOne.label
		self.update()
	}
	showscChoice(){
		if (!self.reportItem.userPreferences)
			return true
		else
			if (!self.reportItem.userPreferences.studyCondition)
				return true
		return false
	}	

	doneclick(){
		self.reportItem.isVerified = "Looks Good"
		self.update()
	}
	</script>

    

<style scoped>
	.text{
		font-size: 10pt;
		margin: 0px;

	}
	.isSelected{
		background-color: aliceblue;
	}
</style>
</reportcell>