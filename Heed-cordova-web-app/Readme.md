# Cordova Web App 


### Protocol for changing study condition

    ```
    firebase.database().ref('users/' + "gparuthi" +'/preferences/').update({'studyCondition': 'OnlyDevice'})

    evalref = firebase.database().ref('users/' + "gparuthi" +'/eval/')
    evalref.push().set('appTag.loadUserPreferences()')
    evalref.push().set('app.sendActivityNotification()')
    ```


### For updating immediately:

    ```
    evalref = firebase.database().ref('users/' + "gparuthi" +'/eval/')
    evalref.push().set('codePush.sync(null, { updateDialog: false, installMode: InstallMode.IMMEDIATE });')
    ```


### For showing certain notification
    ```
    evalref = firebase.database().ref('users/' + "gparuthi" +'/eval/')
    evalref.push().set('app.sendActivityNotification()')
    ```


## Diary: Copy device reports from one user to another

```


keys = _.filter(_.keys(d.deviceReports), dd => {return dd.indexOf("F7")>=0 && dd.indexOf("04-1")>=0 })

fv = _.map(keys, k=>{v = d.deviceReports[k]; v.touchButtonLabel = "Activity:Work";v.userPreferences = {}; v.userPreferences.location = "Home desk"; return v})

updates = {}
_.each(fv, v=>{u = "users/priyank/deviceReports/"+v.uniqueHash; updates["users/priyank/deviceReports/"+v.uniqueHash] =  v})

firebase.database().ref().update(updates).then(function(){
            console.log('BLE-DataSaved', updates);
            
          })     

```

## Remove all logs for a user
```
firebase.database().ref('/logs').orderByChild('userId').equalTo("gparuthi").once("value", function(snapshot){
snapshot.forEach(function(data) {
    firebase.database().ref('/logs').child(data.getKey()).remove()
    });

    });
```

## To get number of log entries
```
firebase.database().ref('/logs').orderByChild('userId').equalTo("gparuthi").once("value", function(snapshot){
console.log(_.keys(snapshot.val()).length)

    });
```