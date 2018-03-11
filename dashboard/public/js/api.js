API = {}

API.getAllLogs = function(c, userId){
	return firebase.database().ref(c).orderByChild('userId').equalTo(userId).once("value", function(snapshot){
		let promise = new Promise((resolve, reject) => {
	    allEvents = _.values(snapshot.val())
		  console.log("Done "+ allEvents.length);
		  resolve(allEvents)
	});
	return promise;
	})
}

API.getAllLogsText = function(logs){
	allText = _.map(logs,d => {
	        let hrsdiff = (moment()-moment(d.time))/1000/60/60
	        return Math.round(hrsdiff*10)/10  + " | " + d.userId + " | " + d.text 
	    }
    );
}