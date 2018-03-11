<chooseone>
<div>
  <h6>{headertext}</h6>
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
      self.chosenOne = {}

      self.on("mount", function(){
        self.update()
      })

      self.on("update", function(){
        self.options = self.opts.options
        self.headertext = self.opts.headertext
        self.showOther = self.opts.showother || true

      })

      chooseLabelClick(e){
        self.chosenOne = e.item
        self.parent.update()
      }

      editOtherText(e){
        self.otherText = e.target.value
        self.update()
      }

      isOtherEnable(){
        return (self.otherText.value.length == 0)
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
          <button onclick={chooseLabelClick}  each={options} class="mdl-button mdl-js-button"> <span class={selected: (label == parent.chosenOne.label)}>{label}</span></button>
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
      self.chosenOne = {}

      self.on("mount", function(){
        self.update()
      })

      self.on("update", function(){
        self.options = self.opts.options
        self.headertext = self.opts.headertext
        self.showOther = self.opts.showother || true

      })

      chooseLabelClick(e){
        self.chosenOne = e.item
        self.parent.update()
      }

      editOtherText(e){
        self.otherText = e.target.value
        self.update()
      }

      isOtherEnable(){
        return (self.otherText.value.length == 0)
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
</choosemultiple>