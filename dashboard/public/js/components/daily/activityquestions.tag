<activityquestions>

<div class="">
	<div  if={reportItem} class="mdl-grid">
		<div class="mdl-cell mdl-cell--12-col ">
			<h3>At {moment(reportItem.time).format("LT")}</h3>
		</div>

		

		<div class="mdl-cell mdl-cell--12-col ">

		<p>
			<span class="header">Activity: </span>{reportItem.activity} 
			<span class="header">Location: </span>{reportItem.location}
			<span class="header">WithPeople: </span>{reportItem.withPeople}
			<span class="header">deviceType: </span>{reportItem.deviceType}
		</p>

		<div class="mdl-cell mdl-cell--12-col">
			<p>
				1. Is the report correct?
				<chooseone ref="verifyReportOptions" showOther=0 headertext="" options={verifyReportOptions}></chooseone>
			</p>
			 
		</div>

		<div class="onetabmargin" hide={isVerified()} > 
			<tb label="Whats wrong?" ref="whatsWrongText" textvalue={reportItem.whatsWrong}></tb>
		</div>

		</div>

		<div class="mdl-cell mdl-cell--12-col ">

		<div>
			
			<p>
				2. Were you triggered to report by a notification (on phone or device)?
				<chooseone ref="didSeeNotificationOptions" showOther=0 headertext="" options={ didSeeNotificationOptions }></chooseone>

			</p>
			<p hide={!isNotified()}>
				You responded on the {reportItem.deviceType}. Where did you see the notification?

				 <chooseone ref="wasNotifiedOnSameDeviceOptions" showOther=0 headertext="" options={ wasNotifiedOnSameDeviceOptions }></chooseone>
			</p> 

			
			
		</div>

		</div>

		<div class="mdl-cell mdl-cell--12-col ">

		<p>
			3. Please tell us anything else about your report? 
			<div class="header onetabmargin">Were you disrupted? Was it awkward?</div>

			<tb class="onetabmargin" label="" ref="commentText" textvalue={reportItem.comment}></tb>
		</p>

		</div>

		<div class="mdl-cell mdl-cell--12-col">
				<button class="mdl-button mdl-js-button  mdl-button--colored" onclick={next}>Done</button>
		</div>
	</div>



	<div  if={!reportItem} class="mdl-grid">
		<div class="mdl-cell mdl-cell--12-col">
			<h5>Please select a report to begin</h5>
		</div>
	</div>
</div>

<script>
    var self = this
    activityquestionsTag = this
	self.reportItem = parent.selectedReportItem

	self.verifyReportOptions = [{label:"Looks Good"}, {label:"Its Wrong"}]
	self.didSeeNotificationOptions = [{label:"Yes I saw it"}, {label:"Nope, didn't see"}, {label:"Don't remember"}]
	self.wasNotifiedOnSameDeviceOptions = [{label:"Phone"}, {label:"Device"}]

	

	updateReportItem(reportItem){
		self.parent.save()
		self.reportItem = undefined
		self.update()

		self.reportItem = reportItem
		self.update()

		self.refs.verifyReportOptions.updateChosenLabel(self.reportItem.isVerified)
		self.refs.didSeeNotificationOptions.updateChosenLabel(self.reportItem.didSeeNotification)
		self.update()

		
		self.refs.wasNotifiedOnSameDeviceOptions.updateChosenLabel(self.reportItem.wasNotifiedOnSameDevice)
		self.update()
	}

	next(){
		self.reportItem.done = true
		self.reportItem.isVerified = self.refs.verifyReportOptions.chosenOne.label
		self.reportItem.didSeeNotification = self.refs.didSeeNotificationOptions.chosenOne.label
		self.reportItem.whatsWrong = self.refs.whatsWrongText.text
		self.reportItem.comment = self.refs.commentText.text
		
		self.reportItem.wasNotifiedOnSameDevice = self.refs.wasNotifiedOnSameDeviceOptions.chosenOne.label
		
		console.log(self.reportItem);
		self.parent.next()
	}

	isNotified(){
		return self.refs.didSeeNotificationOptions.chosenOne.label== self.didSeeNotificationOptions[0].label
	}

	isVerified(){
		return self.refs.verifyReportOptions.chosenOne.label=== self.verifyReportOptions[0].label
	}

</script>

    
	<style>
		.onetabmargin{
			margin-left: 20px;
		}
	</style>
</activityquestions>