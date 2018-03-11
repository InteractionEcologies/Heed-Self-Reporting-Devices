<container>
	<div class="status">
		{status}
	</div>
	<div class="content">
		<div id="myDiv" style="left: 0; width: 100%; height: 400px;"><!-- Plotly chart will be drawn inside this DIV --></div>

		<ol>
			<li each={records} class={newData: isNew}>
				{time.toISOString()} | {value}
			</li>
		</ol>

		
	</div>
	<button onclick={tryAgain}>Try again</button>
	<script>

		self = this
		containerTag = this

		this.records = []//[{"time":"2017-01-02T16:52:00.000Z","value":"939"}]
		this.status = "Loading..."
		this.on("mount", function(){
			self.updatePlot()
		})

		tryAgain(){
			self.records = []
			self.updatePlot()
			app.sendMessage("Go")
		}

		updatePlot(){
			var data = [
			{
				x: _.pluck(self.records, "time"),
				y: _.pluck(self.records, "value"),
				type: 'scatter'
			}
			];

			Plotly.newPlot('myDiv', data);
			self.update()
		}

		updateStatus(message){
			// this.records = []
			this.status = message
			this.updatePlot()
		}

		setData(data){
			console.log("here");
			this.records = []
			// console.log(_.keys(data));
			var recs = _.flatten(_.pluck(_.values(data),"records"))
			self.records = _.uniq(recs, function(item, key) { 
				return item.time.toISOString();
			});

			self.updatePlot()
		}
		addRec(rec){
			self.records.push(rec)
			self.updatePlot()
		}
	</script>
	<style scoped>
		.newData {
			color: red;
		}
	</style>
</container>