if(isAndroid() || isiOS()){
  console.log("Mobile detected");
	$('head').append('<script src="cordova.js"></script>');
	$('head').append('<script src="libs/evothings/evothings.js"></script>');
	$('head').append('<script src="libs/evothings/ui/ui.js"></script>');
	$('head').append('<script src="app.js"></script>');
} else {
  console.log("Web detected");
  
}


function isAndroid(){
  return navigator.userAgent.indexOf("Android") > 0;
}

function isiOS(){
  return ( navigator.userAgent.indexOf("iPhone") > 0 || navigator.userAgent.indexOf("iPad") > 0 || navigator.userAgent.indexOf("iPod") > 0);
}


class TimedMethod {
	constructor(freqInSeconds, toExec){
		this._freqInSeconds = freqInSeconds;
		this._toExec = toExec;
		this._lastTIme = moment();
		console.log("Init a timer with freq = " + this._freqInSeconds);
	}

	check(){
		let curTime = moment();
		let secondsSince = curTime.diff(this._lastTIme, "seconds");
		if (secondsSince > this._freqInSeconds){
			this._lastTIme = curTime;
			this._toExec();
		}
	}

	reset(timestamp){
		// resets the last reported timestamp
		timestamp = timestamp || moment()
		this._lastTIme = timestamp;
	}

}


APP_DEV_MODE = false