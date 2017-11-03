import $ from "jquery"
import {Socket} from "phoenix"
import Highcharts from "highcharts"

export let initialize = (csrfToken) => {
  let socket = new Socket("/socket");
  socket.connect();

  let channel = socket.channel("metrics");
  channel.join().
    receive("ok", (initialMessage) => {
      updateDashboard(initialMessage.points[initialMessage.points.length - 1]);

      let time = 0;
      let jobs_rates = []
      let schedulers_usages = []

      initialMessage.points.reverse().forEach(entry => {
        jobs_rates.push({x: time, y: entry.jobs_rate})
        schedulers_usages.push({x: time, y: entry.schedulers_usage / entry.scheduler_count * 100})
        time -= 0.1
      })

      successChart.series[0].setData(jobs_rates.reverse(), true, false);
      schedulerChart.series[0].setData(schedulers_usages.reverse(), true, false);
    });

  let count = 0;
  let addEntry = (entry) => {
    if (count == 0) updateDashboard(entry)
    count = (count + 1) % 10

    updateHistoryChart(successChart, entry.jobs_rate);
    updateHistoryChart(schedulerChart, entry.schedulers_usage / entry.scheduler_count * 100);
  }

  let updateDashboard = (entry) => {
    $("#workersCount").html(entry.workers_count.toLocaleString("US"))
    $("#jobRate").html(entry.jobs_rate.toLocaleString("US"))
    $("#schedulerUsage").html(`${entry.schedulers_usage.toFixed(2)} / ${entry.scheduler_count}`)
    $("#memoryUsage").html(`${entry.memory_usage.toLocaleString("US")} MB`)
  }

  channel.on("update", addEntry);

  $("#loadForm").submit((event) => {
    post("change_load", {desired_load: parseInt($("#desired_load").val())})
    event.preventDefault();
  });

  $("#failureForm").submit((event) => {
    post("change_failure_rate", {failure_rate: parseInt($("#desired_failure_rate").val())})
    event.preventDefault();
  });

  $("#schedulersForm").submit((event) => {
    post("change_schedulers", {schedulers: parseInt($("#desired_schedulers").val())})
    event.preventDefault();
  });

  let post = (operation, data) => {
    $.ajax({
      method: "POST",
      url: `/load/${operation}`,
      data: JSON.stringify(data),
      contentType: 'application/json',
      headers: {"x-csrf-token": csrfToken},
    });
  }

  let successChart = new Highcharts.Chart({
    chart: {
      renderTo: 'successChart',
      defaultSeriesType: 'line',
      height:'300px'
    },
    title: {text: 'success rate'},
    plotOptions: {line: {marker: {enabled: false}}},
    xAxis: {type: 'integer', min: -60, max: 0},
    yAxis: {min: 0, opposite: true, title: {text: 'jobs/sec', margin: 10}},
    series: [{showInLegend: false, name: 'Successful jobs', data: []}]
  });

  let schedulerChart = new Highcharts.Chart({
    chart: {
      renderTo: 'schedulerChart',
      defaultSeriesType: 'line',
      height:'300px'
    },
    title: {text: 'scheduler usage'},
    plotOptions: {line: {marker: {enabled: false}}},
    xAxis: {type: 'integer', min: -60, max: 0},
    yAxis: {min: 0, max: 100, tickInterval: 10, opposite: true, title: {text: '%', margin: 10}},
    series: [{showInLegend: false, name: 'usage', data: []}]
  });

  let updateHistoryChart = (chart, value) => {
    let newData = [];
    let seriesData = chart.series[0].data;
    let length = seriesData.length;
    for (var i = Math.max(length - 600, 0); i < length; i++){
      newData.push({x: seriesData[i].x - 0.1, y: seriesData[i].y});
    }
    newData.push({x: 0, y: value});
    chart.series[0].setData(newData, true, false);
  }
}
