<tb>
  <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
    <input class="mdl-textfield__input" type="text" id={opts.label} value={opts.textvalue} name={opts.label} onkeyup={updateText} onchange={changeevent}>
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
      // console.log(this.text);
      if (opts.keyupevent)
        opts.keyupevent(e)
    }
    changeevent(e){
      if (opts.changeevent)
        opts.changeevent(e)
    }
  </script>
  <style scoped>
    .mdl-textfield{
      width: 100%;
    }
  </style>
</tb>

<mtb>
  <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
    <textarea class="mdl-textfield__input" type="text" id={opts.label} value={opts.textvalue} name={opts.label} rows="3" onkeyup={updateText} onchange={changeevent}></textarea>
    <label class="mdl-textfield__label" for={opts.label}>{opts.label}</label>
  </div>


  <script>
  this.text = ""
  this.on("mount", function(){
    appTag.checkForMDL()
    this.text = opts.textvalue
  })
    updateText(e){
      let t = e.target.value
      this.text = t
      if (opts.keyupevent)
        opts.keyupevent(e)
    }
    changeevent(e){
      if (opts.changeevent)
        opts.changeevent(e)
    }
  </script>
  <style scoped>
    .mdl-textfield{
      width: 100%;
    }
  </style>
</mtb>



<cb>
  <label class="mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect" for="checkbox-1">
    <input type="checkbox" id="checkbox-1" class="mdl-checkbox__input" onchange={updateChoice} checked={choice}>
    <span class="mdl-checkbox__label">{opts.label}</span>
  </label>
  <script>
  this.choice = false
  this.on("mount", function(){
    if (opts.choice)
      this.choice= opts.choice
    appTag.checkForMDL()
  })
    updateChoice(e){
      let t = e.target.value
      this.choice = t
      opts.onchangeevent()
    }
  </script>
  <style :scoped>
    .mdl-textfield{
      /*width: 100%;*/
    }
  </style>

</cb>

<chooseone>
<div>
      <div>
        <div>
          <button onclick={chooseLabelClick}  each={options} class="mdl-button mdl-js-button"> <span class={selected: (label == parent.chosenOne.label)}>{label}</span></button>
        </div>
      </div>
      
      <div if={showOther!="0"}>

      <div class="mdl-textfield mdl-js-textfield">
        <input class="mdl-textfield__input" type="text" id={"otherText"+_riot_id} name="otherText" value={otherText} onkeyup={editOtherText} onchange={addOption}>
        <label class="mdl-textfield__label" for={"otherText"+_riot_id}>New {opts.type}</label>
      </div>
     
    
      </div>
</div>
  

    <script>
      var self = this
      chooseoneTag = this
      self.options = []
      self.headertext = ""
      self.otherText = ""
      self.chosenOne = {}

      self.on("mount", function(){
        self.update()
      })

      self.on("update", function(){
        self.options = self.opts.options.slice(0) // copying the array
        self.headertext = self.opts.headertext
        self.showOther = self.opts.showother || false

      })

      chooseLabelClick(e){
        self.chosenOne = e.item
        if (opts.onlabelclick)
          opts.onlabelclick(self.chosenOne)
        self.parent.update()
      }

      editOtherText(e){
        self.otherText = e.target.value
        self.update()
      }

      updateChosenLabel(label){
        if (label)
          self.chosenOne = {label: label}
        else
          self.chosenOne = {}
      }

      
    
      addOption(e){
        var option = {label: self.otherText}
        self.options.push(option) 
        self.chosenOne = option
        self.otherText = ""
        self.parent.update()
      }


    </script>
    <style scoped>
    .addOtherButton{
      min-width: 20px;
      width: 20px;
      height: 20px;
    }
    .selected{
      font-size: 16px;
      color: green;
    }


    </style>
</chooseone>

<choosemultiple>
<div>
  <h6>{headertext}</h6>
      <div>
        <div>
          <button onclick={chooseLabelClick}  each={options} class="mdl-button mdl-js-button"> <span class={selected: labelInChosen(label)}>{label}</span></button>
        </div>
      </div>
      
      <div if={showOther!="0"}>

      <div class="mdl-textfield mdl-js-textfield">
        <input class="mdl-textfield__input" type="text" id={"otherText"+_riot_id} name="otherText" value={otherText} onkeyup={editOtherText} onchange={addOption}>
        <label class="mdl-textfield__label" for={"otherText"+_riot_id}>New {opts.type}</label>
      </div>
     
      <button disabled={otherText.length<3} class="addOtherButton mdl-button mdl-js-button mdl-button--fab mdl-button--colored" onclick={addOption}>
        <i class="material-icons" >add</i>
      </button>
      </div>
</div>
  

    <script>
      var self = this
      chooseoneTag = this
      self.options = []
      self.headertext = ""
      self.otherText = ""
      self.chosenOnes = {}

      self.on("mount", function(){
        self.update()
      })

      self.on("update", function(){
        self.options = self.opts.options
        self.headertext = self.opts.headertext
        self.showOther = self.opts.showother || true

      })

      chooseLabelClick(e){
        if (self.chosenOnes[e.item.label])
          delete self.chosenOnes[e.item.label]
        else 
          self.chosenOnes[e.item.label] = JSON.parse(JSON.stringify(e.item))
        self.opts.onupdate()

      }

      editOtherText(e){
        self.otherText = e.target.value
        self.update()
      }

      
    
      addOption(e){
        var option = {label: self.otherText}
        self.options.push(option) 
        self.chosenOnes[option.label] = option
        self.otherText = ""
        self.parent.update()
      }

      labelInChosen(label){
        if (self.chosenOnes[label])
          return true
        return false
      }


    </script>
    <style scoped>
    .addOtherButton{
      min-width: 20px;
      width: 20px;
      height: 20px;
    }
    .selected{
      font-size: 16px;
      color: green;
    }


    </style>
</choosemultiple>