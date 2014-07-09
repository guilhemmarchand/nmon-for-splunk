// parallel sets!
// a visualisation technique for multidimensional categorical data
// you can drag the vertical or horizontal axis independently and 
// watch as your data is represented in completely different ways

// --- settings ---
// none for the time being.
// TODO: add settings to choose which data goes where

// --- expected data format ---
// a splunk search like this: index=_internal sourcetype=splunkd_access | table method status

define(function(require, exports, module) {

    var _ = require('underscore');
    var d3 = require('../d3/d3');
    var d3p = require('./contrib/d3-parsets');
    var SimpleSplunkView = require("splunkjs/mvc/simplesplunkview");

    require("css!./parallelsets.css");

    var ParallelSets = SimpleSplunkView.extend({
        moduleId: module.id,

        className: "splunk-toolkit-parellel-sets",

        options: {
            managerid: null,   
            data: "preview",
            tension: 0.5  
        },

        output_mode: "json_rows",

        initialize: function() {
            SimpleSplunkView.prototype.initialize.apply(this, arguments);

            this.settings.enablePush("value");

            this.settings.on("change:tension", this.render, this);
  
            // Set up resize callback. 
            $(window).resize(_.debounce(_.bind(this._handleResize, this), 20));
        },

        _handleResize: function() {
            this.render();
        },

        createView: function() { 
            // Here we wet up the initial view layout
            var margin = {top: 10, right: 10, bottom: 10, left: 10};
            var availableWidth = parseInt(this.settings.get("width") || this.$el.width());
            var availableHeight = parseInt(this.settings.get("height") || this.$el.height());

            this.$el.html("");

            var svg = d3.select(this.el)
                .append("svg")
                .attr("width", availableWidth)
                .attr("height", availableHeight)
                .attr("pointer-events", "all")

            // The returned object gets passed to updateView as viz
            return { container: this.$el, svg: svg, margin: margin};
        },

        // making the data look how we want it to for updateView to do its job
        formatData: function(data) {
            var fields = this.resultsModel.data().fields;
            var objects = _.map(data, function(row) {
                return _.object(fields, row);
            });

            return {
                'results': objects,
                'fields': fields
            }
        },

        updateView: function(viz, data) {
            var that = this;
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
                .append("g")
                .attr("width", graphWidth)
                .attr("height", graphHeight)
                .attr("transform", "translate(" + viz.margin.left + "," + viz.margin.top + ")");
            
            var tension = this.settings.get("tension");
            var fields = data.fields;

            this.parset = d3p()
                .dimensions(fields)
                .width(graphWidth)
                .height(graphHeight)
                .on("sortCategories", function(){
                    that.trigger("sort:categories");
                });

            graph.datum(data.results).call(this.parset);
            
            graph.selectAll("g.ribbon-mouse path")
                .on("click", function(e) {
                    that.trigger('click', {
                        source: e.source.node.name,
                        sourceDimension: e.source.node.dimension.name,
                        target: e.target.node.name,
                        targetDimension: e.target.node.dimension.name,
                        dimension: e.dimension,
                        value: e.count
                    });
                });

            t = graph.transition().duration(500);
            t.call(this.parset.tension(tension));
        }
    });

    return ParallelSets;
});