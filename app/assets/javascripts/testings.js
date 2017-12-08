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
            beginAtZero: true
          }
        }],
         xAxes: [{
          display: true
        }]
      }
    }
  });

  ctx.data('chart-id', myChart.id);
}

function drawBoxplot(data, name, max) {
  var parent = $(`#parent-for-${name}`);
  var ctx = $(`<canvas id='${name}'></canvas>`);
  parent.find('.card-body').append(ctx);

  var myChart = new Chart(ctx, {
      type: 'barError',
      data: data,
      options: {
        responsive: true,
        maintainAspectRatio: false,
        tooltips: {
          callbacks: {
            label: function(tooltipItem, data) {
              return `Mean: ${tooltipItem.yLabel}`;
            },
            afterLabel: function(tooltipItem, data) {
              var str = "Upper: " + data.datasets[tooltipItem.datasetIndex].uppers[tooltipItem.index] + "\n";
              str += "Lower: " + data.datasets[tooltipItem.datasetIndex].lowers[tooltipItem.index];
              return str;
            }
          }
        },
        scales: {
          yAxes: [{
            ticks: {
              max: max,
              stepSize: max/15,
              beginAtZero:true
            }
          }]
        }
      }
  });

  ctx.data('chart-id', myChart.id);
}

