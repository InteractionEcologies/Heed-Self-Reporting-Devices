<logcell>
  <div class="mdl-grid" onclick={parent.logItemClick}>
    <div class="mdl-cell mdl-cell--3-col header">{moment(logitem.time).fromNow()}</div>
    <div class="mdl-cell mdl-cell--3-col header">{logitem.userId}</div>
    <div class="mdl-cell mdl-cell--12-col text">{logitem.text}</div>
  </div>

  self.logitem = opts.logitem
</logcell>

<chart>
  <div id="chart">
    
  </div>
  
  <script>
  var self = this
  chartTag = this
    

    this.on("mount", function(){
      
    })

    drawChart(data){
      if (self.svg)
        d3.select("svg").remove();  
      self.svg = svg = dimple.newSvg("#chart", 600, 200); 
           chart = new dimple.chart(svg, data);
          y = chart.addCategoryAxis("y", "Event");
          x = chart.addCategoryAxis("x", "timestamp");
           x.addOrderRule("Date");
           var s = chart.addSeries("Channel", dimple.plot.bubble);
            s.stacked = false;
          // chart.addSeries(null, dimple.plot.bar);
          chart.setMargins(150, 0, 0, 40); 
          chart.draw();
    }

    updateChart(data){

     _.each(data, function(d){
      d.Date = moment(d.time)
      d.Event = d.text.split('|')[0]
      d.timestamp = d.Date.get("hour") + Math.round(d.Date.get("minute")/60 * 100) / 100
      d.Channel = d.Event
     })
      self.drawChart(data)

    }


    
  </script>
</chart>
