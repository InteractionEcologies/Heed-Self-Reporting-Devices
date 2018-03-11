helpers = {}

helpers.getDeviceReports = function(deviceReports){
	console.log("Device Report cleanup")
	console.log(deviceReports)
		 activityReports = []
		for (var i in deviceReports){
			var deviceReport = deviceReports[i]
			// console.log(deviceReport.uniqueHash + " " + deviceReport.touchButtonLabel);
			
			if (activityReports.length>0){
				var lastActivityReport = activityReports[activityReports.length-1]
				// calculate the time difference from last added report
				let minutesDifference = (moment(deviceReport.time)- moment(lastActivityReport.time))/1000/60
				// console.log(deviceReport);
				var deviceLocation = ""
				if (deviceReport.userDevicePreferences)
					deviceLocation = deviceReport.userDevicePreferences.location
				else 
					deviceLocation = deviceReport.userPreferences.location

				if (minutesDifference < 10 && lastActivityReport.location== deviceLocation){
					// console.log('updating');
					lastActivityReport = helpers.updateActivityReportWithNewDeviceReport(lastActivityReport, deviceReport)
				} else {
					// console.log('new');
					helpers.createNewActivityReport(activityReports ,  deviceReport)
				}
			} else {
				// console.log('first');
				helpers.createNewActivityReport(activityReports, deviceReport)
			}

			// console.log(activityReports[activityReports.length-1].activity);
		}
		activityReports = _.map(activityReports, r=>{r.activity= _.union(r.activity); return r; })
		return activityReports

	}

helpers.createNewActivityReport = function(activityReports, newDeviceReport){
	var nd = {deviceReports : [], time: newDeviceReport.time, userPreferences: newDeviceReport.userPreferences, activity:[], withPeople:"", location:"", deviceType:"BLE"}
	
	nd.uniqueHash = moment(newDeviceReport.time).format() + '-device' 
	nd.createTime = newDeviceReport.time
	
	if(newDeviceReport.userDevicePreferences)
		nd.location = newDeviceReport.userDevicePreferences.location


	nd = helpers.updateActivityReportWithNewDeviceReport(nd, newDeviceReport)
	// console.log("Pusing new to ",activityReports);
	activityReports.push(nd)
}

helpers.updateActivityReportWithNewDeviceReport = function(lastActivityReport, newDeviceReport){

	// find the kind of report: activity or social
	let touchButtonLabel = newDeviceReport.touchButtonLabel
	if (touchButtonLabel.indexOf(":")>=0)
	{
		var values = touchButtonLabel.split(":"), 
		type = values[0],
		label = values[1]

		if (type=="Activity")
			lastActivityReport.activity.push(label)
		if (type=="Social")
			lastActivityReport.withPeople = "Yes"
	} else 
		lastActivityReport.activity.push(touchButtonLabel)

	lastActivityReport.deviceReports.push(newDeviceReport)
	return lastActivityReport


}

helpers.fetchOverallComments = function(date, userData){
	try{
			return userData.days[date].comment
		} catch(e){
			return ""
		}
}

helpers.fetchResearcherComments = function(date, userData){
	try{
			return userData.days[date].researcherComment
		} catch(e){
			return ""
		}
}