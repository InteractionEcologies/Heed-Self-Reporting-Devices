<recorder>
	<div>	

		<button class="mdl-button mdl-js-button mdl-button--fab mdl-button--colored" onclick={record}>
				<i class="material-icons">fiber_manual_record</i>
			</button>

		<button class="mdl-button mdl-js-button mdl-button--fab mdl-button--colored" onclick={upload}>
				<i class="material-icons">cloud_upload</i>
			</button>
	</div>
	
	<script>
		self = this
		recorderTag = this
		
		recorder = new Object
		self.isRecorded = false
		self.savedFilePath = ""

		record(){
			console.log('Starting Recording');
			recorder.record()
		}
		

		this.on("mount", function(){
			recorder.stop = function() {
				window.plugins.audioRecorderAPI.stop(function(msg) {
		    // success
		    alert('ok: ' + msg);
		}, function(msg) {
		    // failed
		    alert('ko: ' + msg);
		});
			}
			recorder.record = function() {
				console.log("recording...");
				window.plugins.audioRecorderAPI.record(
					function(savedFilePath) {
					  	self.isRecorded = true;
					  	self.savedFilePath = savedFilePath
					    alert('ok: ' + savedFilePath);
					}, function(msg) {
					    alert('ko: ' + msg);
					  }, 5); // record 30 seconds
						}
						recorder.playback = function() {
							window.plugins.audioRecorderAPI.playback(function(msg) {
					    // complete
					    alert('ok: ' + msg);
					}, function(msg) {
					    // failed
					    alert('ko: ' + msg);
					});
						}
		})


		upload() {
			var filePath = self.savedFilePath
			console.log("file path = " + JSON.stringify(filePath));

			var storageRef = firebase.storage().ref();

			var getFileBlob = function(url, cb) {
				var xhr = new XMLHttpRequest();
				xhr.open("GET", url);
				xhr.responseType = "blob";
				xhr.addEventListener('load', function() {
					cb(xhr.response);
				});
				xhr.send();
			};

			var blobToFile = function(blob, name) {
				blob.lastModifiedDate = new Date();
				blob.name = name;
				return blob;
			};

			var getFileObject = function(filePathOrUrl, cb) {
					console.log(filePathOrUrl);
  				var fileName = filePathOrUrl.split('/')[filePathOrUrl.split('/').length - 1];
  				var path = cordova.file.dataDirectory + fileName;
  				console.log(path);
  
						window.resolveLocalFileSystemURL(path, function (fileEntry) {
						             fileEntry.file(function (file) {
						                 var reader = new FileReader();
						                 reader.onloadend = function () {
						                          // This blob object can be saved to firebase
						                          var blob = new Blob([new Uint8Array(this.result)], { type: "audio/mp4" });                  
						                          cb(blob);
						                 };
						                 reader.readAsArrayBuffer(file);
						              });
						          }, function (error) {
						              console.log("Error");
						          });
					};
						                 

			getFileObject(filePath, function(fileObject) {
				var fileName = (new Date()).toISOString() + ".m4a"
				var uploadTask = storageRef.child('recordings/'+fileName).put(fileObject);

				uploadTask.on('state_changed', function(snapshot) {
					console.log(snapshot);
				}, function(error) {
					console.log(error);
				}, function() {
					var downloadURL = uploadTask.snapshot.downloadURL;
					console.log(downloadURL);
            // handle image here
        });
			});

		}
		
	</script>
	<style scoped>
		.newData {
			color: red;
		}
	</style>
</recorder>