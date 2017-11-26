// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/

function drawHistogram(caption, data) {
  var parent = $("#histogram-container");
  var ctx = $("<canvas id='histogram'></canvas>");
  parent.find('.card-body').append(ctx);

  var myChart = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: data.map(function(d) { return d.x; }),
      datasets: [{
          label: caption,
          data: data.map(function(d) { return d.y; }),
          backgroundColor:
              'rgba(54, 162, 235, 0.5)',
          borderColor:
              'rgba(54, 162, 235, 1)',
          borderWidth: 1
      }]
    },
    options: {
      title: {
        display: true,
        text: 'test',
        position: 'bottom'
      },
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        yAxes: [{
          display: true,
          scaleLabel: {
              display: true,
              labelString: 'Frequency'
          },
          ticks: {
            stepSize: 2,
            beginAtZero: true
          }
        }],
         xAxes: [{
          display: true,
          scaleLabel: {
              display: false,
              labelString: 'Time'
          }
        }]
      }
    }
  });

  ctx.data('chart-id', myChart.id);
}

function drawBoxplot(data, name) {
  var parent = $(`#parent-for-${name}`);
  var ctx = $(`<canvas id='${name}'></canvas>`);
  parent.find('.card-body').append(ctx);

  var myChart = new Chart(ctx, {
      type: 'barError',
      data: data,
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          yAxes: [{
            ticks: {
              beginAtZero:true
            }
          }]
        }
      }
  });

  ctx.data('chart-id', myChart.id);
}

