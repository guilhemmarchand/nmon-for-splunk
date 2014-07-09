define(function(require, exports, module) {
    var _ = require('underscore');
    var SimpleSplunkView = require('splunkjs/mvc/simplesplunkview');  
    var d3 = require('../d3/d3');

    require('css!./punchcard.css');

    // These ranges are hardcoded as they are the builtin
    // splunk time units. Any other range is calculated from 
    // the range of the data
    // NOTE: _.range excludes the final value, so they are all 1 over
    var TIME_RANGES = {
        'date_hour' : _.range(0, 24),
        'date_minute': _.range(0, 60),
        'date_mday': _.range(1, 32),
        'date_month': [
            'january', 'february', 'march', 
            'april', 'may', 'june', 
            'july', 'august', 'september', 
            'october', 'november', 'december'
        ],
        'date_second': _.range(0, 60),
        'date_wday': ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']
    };
    var LABEL_WIDTH = 200;
    var MIN_RADIUS = 2;
    var MAX_RADIUS = 9;
    var ROW_HEIGHT = MAX_RADIUS * 2 + 2;

    // Returns true if all elements of a list are numbers
    var isNumericList = function (list) {
        return _.every(list, function(i) { return _.isNumber(i); });;
    };

    // Truncates a string to a length, optionally adding a suffix
    var truncate = function(str, maxLength, suffix) {
        maxLength = maxLength || 25;
        suffix = suffix || '...';
        if (str.length > maxLength) {
            str = str.substring(0, maxLength + 1); 
            str = str + suffix;
        }
        return str;
    }

    // Rounds to thousands and adds a 'K'
    var roundToThousands = function(d) { 
        var value = d[1]; 
        if (value > 1000) {
            value = Math.round((value / 1000)) + 'K';
        }
        return value;
    }

    var PunchcardView = SimpleSplunkView.extend({
        moduleId: module.id,

        className: 'splunk-toolkit-punchcard', 

        options: {
            managerid: null,  
            data: 'preview',
            formatXAxisLabel: _.identity,
            formatYAxisLabel: truncate,
            formatCount: roundToThousands
        },

        output_mode: 'json',

        initialize: function() {
            SimpleSplunkView.prototype.initialize.apply(this, arguments);

            // Listen to changes
            this.settings.on('change:formatXAxisLabel change:formatYAxisLabel change:formatCount', this.render, this);

            // Set up resize callback. 
            $(window).resize(_.debounce(_.bind(this._handleResize, this), 20));
        },

        _handleResize: function() {
            this.render();
        },

        createView: function() {
            // Here we set up the initial view layout
            var margin = {top: 30, right: 30, bottom: 30, left: 30};
            var availableWidth = parseInt(this.settings.get('width') || this.$el.width(), 10);
            var availableHeight = parseInt(this.settings.get('height') || this.$el.height(), 10);

            this.$el.html("");

            var svg = d3.select(this.el)
                .append('svg')
                .attr('width', availableWidth)
                .attr('height', availableHeight)
                .attr('pointer-events', 'all');

            // The returned object gets passed to updateView as viz
            return { container: this.$el, svg: svg, margin: margin};
        },

        formatData: function(data) {
            var rows = data;

            // Get dimension names from a sample object
            var sampleKeys = _.keys(data[0]);
            var xDimension = sampleKeys[0];
            var yDimension = sampleKeys[1];

            var categories = {};
            var currentCategory = 1;

            // We keep the possible values of 
            // x for calculating the x scale later
            var xValues = [];

            var countData = {};
            _.each(rows, function(row) {
                var name = row[yDimension];
                var category = currentCategory++;
                var count = parseInt(row.count, 10);

                var xValue = row[xDimension];
                xValues.push(xValue);

                countData[name] = countData[name] || { total: 0, name: name, counts: [], category: category };
                countData[name]['total'] += count;
                countData[name]['counts'].push([xValue, count])
            });

            // Dedupe range values
            xValues = _.uniq(xValues);

            var metadata = { xDimension: xDimension, yDimension: yDimension, xValues: xValues };        

            return { metadata: metadata, countData: _.values(countData) };
        },

        updateView: function(viz, data) {
            var that = this;
            var formatXAxisLabel = this.settings.get('formatXAxisLabel');
            var formatYAxisLabel = this.settings.get('formatYAxisLabel');
            var formatCount = this.settings.get('formatCount');

            var containerHeight = this.$el.height();
            var containerWidth = this.$el.width(); 

            // Clear svg
            var svg = $(viz.svg[0]);
            svg.empty();
            svg.height(containerHeight);
            svg.width(containerWidth);

            // Add the graph group as a child of the main svg
            var graphWidth = containerWidth - viz.margin.left - viz.margin.right
            var graphHeight = containerHeight - viz.margin.top - viz.margin.bottom;
            var graph = viz.svg
                .append('g')
                .attr('width', graphWidth)
                .attr('height', graphHeight)
                .attr('transform', 'translate('  
                        + viz.margin.left + ','  
                        + viz.margin.top + ')');

            var colorScale = d3.scale.category20();

            // If we have a hardcoded set of xValues, we use it, 
            // otherwise it comes from the data
            var xValues =  TIME_RANGES[data.metadata.xDimension]
                || data.metadata.xValues;

            // If the x scale is numbers, we make it linear, otherwise its ordinal
            var xScale = null;
            if (isNumericList(xValues)) {
                var start = _.min(xValues);
                var end = _.max(xValues);
         
                xScale = d3.scale.linear()
                    .domain([start, end])
                    .range([0, graphWidth - LABEL_WIDTH]);
            }
            else {
                xScale = d3.scale.ordinal()
                    .domain(xValues)
                    .rangePoints([0, graphWidth - LABEL_WIDTH]);
            }

            // Set up the axis markers
            var xAxis = d3.svg.axis()
                .scale(xScale)
                .ticks(xValues.length + 1)
                .tickFormat(formatXAxisLabel)  
                .orient('top');

            graph.append('g')
                .attr('class', 'x axis')
                .call(xAxis);

            for (var j = 0; j < data.countData.length; j++) {
                var row = data.countData[j];

                // Append a category class
                var g = graph.append('g')
                    .attr('class','dimension') 
                    .attr('data-category', row.category);

                // Add circles
                var circles = g.selectAll('circle')
                    .data(row['counts'])
                    .enter()
                    .append('circle');

                // Add text
                var text = g.selectAll('text')
                    .data(row['counts'])
                    .enter()
                    .append('text');

                // Scaler for radius
                var rScale = d3.scale.linear()
                    .domain([0, d3.max(row['counts'], function(d) { return d[1]; })])
                    .range([MIN_RADIUS, MAX_RADIUS]);

                // Position and color the circles
                circles
                    .attr('cx', function(d, i) { return xScale(d[0]); })
                    .attr('cy', j * ROW_HEIGHT + ROW_HEIGHT)
                    .attr('r', function(d) { return rScale(d[1]); })
                    .style('fill', function(d) { return colorScale(row.category); })
                    .on('mouseover', mouseover)
                    .on('mouseout', mouseout)
                    .append('svg:title')
                        .text(function(d) { return d[1]; });

                // Position and color the numbers 
                text
                    .attr('y', j * ROW_HEIGHT + ROW_HEIGHT + 5)
                    .attr('x',function(d, i) { return xScale(d[0])-5; })
                    .attr('class','value')
                    .on('mouseover', mouseover)
                    .on('mouseout', mouseout)
                    .text(formatCount)
                    .attr('title', function(d) { return d[1]; })
                    .style('fill', function(d) { return colorScale(row.category); })
                    .style('display','none');

                // Position and color the labels
                g.append('text')
                    .attr('y', j * ROW_HEIGHT + ROW_HEIGHT + 5)
                    .attr('x', graphWidth - LABEL_WIDTH + 25)
                    .attr('class','label')
                    .text(formatYAxisLabel(row['name']))
                    .style('fill', function(d) { return colorScale(row.category); })
                    .on('mouseover', mouseover)
                    .on('mouseout', mouseout)
            };

            // On mouseover circles in the row are hidden
            // and replaced with number values. The number being moused 
            // over is also turned black
            function mouseover(p) {
                var g = d3.select(this).node().parentNode;
                var element = d3.select(this);
                element.attr('storedFill', element.style('fill'));
                element.style('fill', 'black');
                element.style('font-weight', 'bold');
                d3.select(g).selectAll('circle').style('display','none');
                d3.select(g).selectAll('text.value').style('display','block');
            }
     
            function mouseout(p) {
                var g = d3.select(this).node().parentNode;
                var element = d3.select(this);
                element.style('fill', element.attr('storedFill'));
                element.style('font-weight', 'normal');
                d3.select(g).selectAll('circle').style('display','block');
                d3.select(g).selectAll('text.value').style('display','none');
            }
        }
    });
    return PunchcardView;
});