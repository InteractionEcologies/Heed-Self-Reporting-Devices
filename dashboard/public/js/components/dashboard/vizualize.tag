<plot>
	<div id={divid}></div>
	<script>
		var self = this
		self.divid = "p"+self.opts.id+self.opts.filters[0]

		this.on("mount", function(){
			this.parent.on("dataupdate", function(){
				console.log("dataupdated", self.opts);
				self.updatePlot()
			})
		})

		updatePlot(){
			self.data = self.opts.data
			self.filters = self.opts.filters

			if (self.data){
				let plotdata = []

				_.each(self.filters, f=>{
					// console.log(f);
					let flogs = _.filter(self.data, l=>{
						return l.text.indexOf(f)>=0 && l.userId.indexOf(self.opts.id)>=0
					})
					// console.log(flogs.length);
					
					let x = _.pluck(flogs, 'time')
					let y = _.map(flogs, d=>{return plotdata.length+1})
					let texts = _.pluck(flogs, 'text')
					x.unshift(moment(moment()-24*60*60*1000).format()); y.unshift(0); texts.unshift("");
					x.push(moment().format()); y.push(0); texts.push("");

					plotdata.push({
					x : x,
					y : y,
					text: texts,
    				mode: 'markers',
    				name: f
					})

				})

				var adds = self.parent.additionalSources[self.filters[0]]
				if (adds){
					console.log(adds);
					_.each(adds, function(fr){
						
						fr.y = _.map(fr.x, d=>{return plotdata.length+1})
						fr.mode= 'markers'
						console.log("Adding new plot");
						plotdata.push(fr)
					})					
				} else {
					console.log("cant find ", self.filters[0], self.parent.additionalSources);
				}

				

				

				var layout = {
				  title: self.filters[0],
				  height: 300,
				  width: 900,
				  yaxis: {
				      showgrid: false,
				      zeroline: false,
				      showline: false,
				      mirror: 'ticks',
				      showticklabels: false
				    },
				  // l: 0,
			   //    r: 0,
			   //    b: 0,
			   //    t: 0,
			   //    pad: 1
				};
				Plotly.newPlot(self.divid, plotdata, layout, {displayModeBar: showDisplayModeBar});
			}
		}
	</script>
</plot>


<userdata>
<div>
	<h4>{opts.user.label}</h4>
	<button class="mdl-button mdl-js-button  mdl-button--colored" onclick={getAllData} class="ui" waves-center="true">
             Get All Data
    </button>
	<div class="mdl-grid">
		<div class="mdl-cell mdl-cell--12-col" each={f in filters}>
			<plot  id={parent.opts.user.label} data={parent.allEvents} filters={f}>	
		</div>
	</div>
</div>
	<script>
	var self = this

	self.filters = [["NotifyingNearbyDevices"], ["Ping", "Location", "Loaded"], ["Touch"], ["User Notified", "OnActivityReportActivity"], ["NotifyingNearbyDevices", "STILL", "ON_FOOT", ]]

	self.additionalSources = {}

	this.on("mount", function(){
		// console.log(self.opts);
		self.userId = self.opts.user.label
		// self.allEvents = allLogs['logs']
		// self.trigger("dataupdate")

		self.userref = firebase.database().ref('users/' + self.userId)
		self.userref.once("value", snapshot=>{
			self.allData = snapshot.val()
			self.getAllData()
		})

		
	})
	getAdditionalSources(){
		self.additionalSources.NotifyingNearbyDevices = (function f(){
			var frd = _.values(self.allData.finalreports)
			let getfr= function(dytpe){
				fr1d = _.filter(frd, d=>{return d.deviceType==dytpe})
				var fr1 = {}
				fr1.x = _.map(fr1d, d=>{return moment(d.createTime).format()})
				fr1.text = _.map(fr1d, d=>{return dytpe})
				fr1.name = dytpe
				return fr1
			}
			var ret = [getfr("Phone"), getfr("BLE")]

			return ret
		})()
	}

	getAllData(){

		return firebase.database().ref('/logs').orderByChild('userId').equalTo(self.userId).once("value", function(snapshot){
		  let allData = _.values(snapshot.val())
		  // allData = _.map(allData, l=>{l.text = l.text.toString(); return l})
		  self.allEvents = allData
		  self.getAdditionalSources()
		  self.update()
		  self.trigger("dataupdate")
		  // console.log("found "+ allData.length);

		})
	}

	</script>
</userdata>

<vizualize>

<div class="container">
	
	<div>
		<choosemultiple ref="chooseUsers" options={userlist} headertext="" showOther=0 onupdate={updateFilter}></choosemultiple>
		<button class="mdl-button mdl-js-button  mdl-button--colored" onclick={toggleDisplayMode} class="ui" waves-center="true">
		      Display Mode
	    </button>
	</div>
	
	<div if={refs.chooseUsers.chosenOnes[user.label] && show} each={user in userlist}>
		<userdata user={user} ></userdata>
	</div>

		
	
</div>

<script>
	var self = this
	vizTag = this

	self.userlist = []
	showDisplayModeBar = false
	self.show = true

	toggleDisplayMode(){
		showDisplayModeBar = !showDisplayModeBar
		self.show = false
		self.update()
		self.show= true
		self.update()
	}

	
	appTag.on("alllogsLoadedlogs", function(){
		self.userlist = atags.logs.userlist.slice()
		logs = atags["logs"].logs;
		finalLogs = _.map(logs, s=>{
		  if (s.text)
		  {

		    if (s.text.indexOf("Ping")>=0)
		    {
		      if (s.data.LatestResult)
		       s.text += " | ScreenOff = " + s.data.LatestResult.ScreenOff
		   }}

		   return s;

		 });
		riot.update()
		// self.update()
	})
	updateFilter(){
		// c = self.refs.chooseUsers.chosenOnes;
		// console.log(c);
		self.update()
	}
</script>

</vizualize>