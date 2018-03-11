<reportmodal>
  <dialog class="mdl-dialog">
    <div class="mdl-dialog__content">
       <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label ">
        <input class="mdl-textfield__input" type="text" id="mact" name="mact" value={modalItem.activity}>
        <label class="mdl-textfield__label" for="mact">Activity</label>
      </div>
      <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label ">
        <input class="mdl-textfield__input" type="text" id="mloc" name="mloc" value={modalItem.location}>
        <label class="mdl-textfield__label" for="mloc">Location</label>
      </div>
      <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
        <input class="mdl-textfield__input" type="text" id="mwid" name="mwid" value={modalItem.withPeople}>
        <label class="mdl-textfield__label" for="mwid">With someone?</label>
      </div>
      <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
        <input class="mdl-textfield__input" type="text" id="mcom" name="mcom" value={modalItem.comments}>
        <label class="mdl-textfield__label" for="mcom">Comments</label>
      </div>

    </div>
    <div class="mdl-dialog__actions ">
      <div class="mdl-dialog__actions">
      <button type="button" class="mdl-button close">Done</button>
    </div>
    </div>
  </dialog>
  <script>
  var self= this
  self.modalItem = {activity: "", location:"", withPeople:"", comments:""}
  self.on("update",function(){
    appTag.checkForMDL();
  })
    show(item, onDone){
      self.modalItem = item
      self.update()

      var dialog = document.querySelector('dialog');
        var showModalButton = document.querySelector('.show-modal');
        if (! dialog.showModal) {
          dialogPolyfill.registerDialog(dialog);
        }
        
          dialog.showModal();
        
        dialog.querySelector('.close').addEventListener('click', function() {
          dialog.close()
          onDone()
        });

    }
  </script>
</reportmodal>