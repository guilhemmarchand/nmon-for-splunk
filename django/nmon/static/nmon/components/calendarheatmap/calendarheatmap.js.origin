

// calheat!
// shows a cool looking heatmap based on different time signatures
// requires a timechart search. it dynamically guesses how to set up the
// way to show the time, but you can define any settings you want in the html
// docs: http://kamisama.github.io/cal-heatmap

// ---settings---

// domain: (hour, day, week, month, year)
// subDomain: (min, x_min, hour, x_hour, day, x_day, week, x_week, month, x_month)
//       -- x_ variants are used to rotate the reading order to left to right, then top to bottom.
// start: set to 'current' for current time or 'earliest' for your earliest data point

// TODO:
// add a setting for each option at http://kamisama.github.io/cal-heatmap/#options
//      rather than using the JS method in the HTML like i'm doing now.



// the data is expected in this format after formatData (epoch time: event count): 
// {
//    "timestamps":[
//       {
//          "1378225500":"8",
//          "1378225560":"8",
//          "1378225620":"8",
//       },
//       {
//          "1378230300":"4",
//          "1378230360":"4",
//          "1378230660":"2"
//       },
//       {
//          "1378225500":"7",
//          "1378225560":"7",
//       },
//       {
//          "1378225500":"6",
//          "1378225560":"6",
//          "1378225620":"7",
//       },
//       {
//          "1378225500":"41",
//          "1378225560":"41",
//       },
//       {
//          "1378225500":"22",
//          "1378225560":"22",
//       }
//    ],

// -- we add this part onto the actual data --

//    "start":"2013-09-03T16:25:00.000Z",
//    "domain":"hour",
//    "subDomain":"min"
// }

define(function(require, exports, module) {
 
    var _ = require('underscore');
    var SimpleSplunkView = require("splunkjs/mvc/simplesplunkview");
    var d3 = require("../d3/d3");
    var CalHeatMap = require("./contrib/cal-heatmap");

    require("css!./calendarheatmap.css");

    var CalendarHeatMap = SimpleSplunkView.extend({
        moduleId: module.id,

        className: "splunk-toolkit-cal-heatmap",

        heatmapOptionNames: [
            'cellRadius', 'domainMargin', 'maxDate', 'dataType', 
            'considerMissingDataAsZero', 'verticalOrientation', 
            'domainDynamicDimension', 'label', 'legendCellSize', 
            'legendCellPadding', 'legendMargin', 'legendVerticalPosition', 
            'legendHorizontalPosition', 'domainLabelFormat', 
            'subDomainDateFormat', 'subDomainTextFormat', 'nextSelector', 
            'previousSelector', 'itemNamespace', 'onMaxDomainReached', 
            'onMinDomainReached', 'width', 'height'],
       
        options: {
            managerid: "search1",   // your MANAGER ID
            data: "preview",  // Results type
            domain: 'hour', // the largest unit it will differentiate by in squares
            subDomain: 'min', // the smaller unit the calheat goes off of
            uID: null,
            range: 4
        },

        validDomains: {
            'min': ['hour'],
            'hour': ['day', 'week'],
            'day': ['week', 'month', 'year'],
            'week': ['month', 'year'],
            'month': ['year']
        },

        output_mode: "json_rows",

        initialize: function() {
            var that = this;
            SimpleSplunkView.prototype.initialize.apply(this, arguments);
            this.settings.enablePush("value");
            // whenever domain or subDomain are changed, we will re-render.
            this.settings.on("change:domain", this.onDomainChange, this);
            this.settings.on("change:subDomain", this.onDomainChange, this);
            this.settings.on("change", this._onSettingsChange, this);
            var uniqueID=Math.floor(Math.random()*1000001);
            this.settings.set("uID", uniqueID);
        },

        onDomainChange: function() {
            var dom = this.settings.get('domain');
            var sd = this.settings.get('subDomain');

            // Knock off the prefix cause it doesnt matter here
            var sdShort = sd.replace("x_", "");

            // If the current domain is valid for this subdomain 
            if (_.contains(this.validDomains[sdShort], dom)){
                this.render();
            }
            else{
                console.log(sd + " is and invalid subDomain for " + dom);
            }
        },

        _onSettingsChange: function(changed) {
            // Route heatmap visualization changes to the renderer
            if ((_.intersection(_.keys(changed.changed), this.heatmapOptionNames)).length > 0) {
                this.render();
            }
        },

        createView: function() { 
            return true;
        },

        // making the data look how we want it to for updateView to do its job
        // in this case, it looks like this:
        // {timestamp1: count, timestamp2: count, ... }
        formatData: function(data) {              
            var rawFields = this.resultsModel.data().fields;
            var domain = this.settings.get('domain');
            var subDomain = this.settings.get('subDomain');
            
            var filteredFields = _.filter(rawFields, function(d){ return d[0] !== "_"; });
            var objects = _.map(data, function(row) {
                return _.object(rawFields, row);
            });

            var series = [];
            for(var i = 0; i < filteredFields.length; i++) {
                series.push({ name: filteredFields[i], timestamps: {}, min: Number.POSITIVE_INFINITY, max: Number.NEGATIVE_INFINITY });
            }
            
            _.each(objects, function(object) {
                // Get the timestamp for this object
                var time = new Date(object['_time']);
                var timeValue = time.valueOf() / 1000;
                
                // For each actual value, store it in the timestamp object
                _.each(filteredFields, function(field, i) {
                    var value = object[field];
                    series[i].timestamps[timeValue] = parseInt(value, 10) || 0;
                    series[i].min = Math.min(series[i].min, value);
                    series[i].max = Math.max(series[i].max, value);
                });
            });
                
            _.each(series, function(serie) {
            
            });
            
            return {
                series: series,
                domain: domain,
                subDomain: subDomain,
                start: new Date(objects[0]['_time']),
                min: new Date(objects[0]['_time']),
                max: new Date(objects[objects.length - 1]['_time'])
            };
        },

        updateView: function(viz, data) {     
            var that = this;
            // Options that can be set externally after instantiation
            // that affect the display. Ensure that any "empty" values
            // are set to null (use default).  Some controls hand back
            // empty strings, which result in nothing being shown.
            // Not what is wanted.

            var vizOptions = _.chain(this.settings.toJSON())
                .pairs()
                .filter(function(kv) { return _.contains(that.heatmapOptionNames, kv[0]); })
                .filter(function(kv) { return ! (_.isNull(kv[1]) || _.isUndefined(kv[1]))  || (kv[1] !== ""); })
                .object()
                .value();

            this.$el.html('');
            _.each(data.series, function(series, idx) {
                var scale = d3.scale.quantile()
                    .domain([series.min, series.max])
                    .range([0,1,2,3,4]);
                var legend = _.map(scale.quantiles(), function(x) { return Math.round(x); });
                
                var $el = $("<div class='heatmap-container'/>").appendTo(that.el);
                var $title = $("<h4 class='heatmap-series-title'>Heatmap for: " + series.name + "</h4>").appendTo($el);
                var $buttons = $("<div class='heatmap-buttons'/>").appendTo($el);
                var $prev = $("<a class='heatmap-prev btn-pill icon-triangle-left'></a>").appendTo($buttons);
                var $next = $("<a class='heatmap-next btn-pill icon-triangle-right'></a>").appendTo($buttons);
                var options = _.extend({
                    itemSelector: $el[0],
                    previousSelector: $prev[0],
                    nextSelector: $next[0],
                    data: series.timestamps,
                    domain: data.domain,
                    subDomain: data.subDomain,
                    start: data.start,
                    range: 4,
                    cellSize: 12,
                    cellPadding: 3,
                    domainGutter: 10,
                    highlight: ['now', new Date()],
                    legend: legend,
                    legendMargin: [0, 0, 20, 0],
                    legendCellSize: 14,
                    minDate: data.min,
                    maxDate: data.max,
                    onMinDomainReached: function(hit) {
                        $prev.attr("disabled", hit ? "disabled" : false);
                    },
                    onMaxDomainReached: function(hit) {
                        $next.attr("disabled", hit ? "disabled" : false);
                    },
                    onClick: function(date, value) { 
                        that.trigger('click', { date: date, value: value });
                        that.settings.set('value', date.valueOf());
                    }
                }, vizOptions);
                
                var cal = new CalHeatMap();
                cal.init(options); // create the calendar using either default or user defined options */
                
                if (idx < data.series.length - 1) {
                    $("<hr/>").appendTo($el);
                }
            });
        }
    });

    return CalendarHeatMap;
});
