<tb>
  <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
    <input class="mdl-textfield__input" autocapitalize="off" type="text" id={opts.label} value={opts.textvalue} name={opts.label} onkeyup={updateText} onchange={changeevent}>
    <label class="mdl-textfield__label" for={opts.label}>{opts.label}</label>
  </div>
  <script>
  this.text = ""
  this.on("mount", function(){
    appTag.checkForMDL()
    this.text = opts.textvalue
    // self.keyupevent = opts.keyupevent
    // self.changeevent = opts.changeevent
  })
    updateText(e){
      let t = e.target.value
      this.text = t
      if (opts.keyupevent)
        opts.keyupevent()
    }
    changeevent(e){
      if (opts.changeevent)
        opts.changeevent()
    }
  </script>
  <style scoped>
    .mdl-textfield{
      width: 100%;
    }
  </style>
</tb>



<tbn>
  <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
    <input class="mdl-textfield__input" type="text" id="userid" name="userId" onkeyup={opts.keyupevent} onchange={updateUserId}>
    <label class="mdl-textfield__label" for="userid">{opts.label}</label>
  </div>
  <script>
  this.on("mount", function(){
    appTag.checkForMDL()
  })
    updateUserId(e){
      let t = e.target.value
      this.text = t
    }
  </script>
  <style scoped>
    .mdl-textfield{
      width: 100%;
    }
  </style>
</tbn>
