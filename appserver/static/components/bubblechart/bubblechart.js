// Bubble Chart
// this displays information as different 'bubbles,' their unique values represented with
// the size of the bubble.
// supports drilldown clicks

// available settings:
// - nameField: the field to use as the label on each bubble
// - valueField: the field to use as the value of each bubble (also dictates size)
// - categoryField: the field to use for grouping similar data (usually the same field as nameField)

// ---expected data format---
// a splunk search like this: source=foo | stats count by artist_name, track_name

define(function(require, exports, module) {

    var _ = require('underscore');
    var d3 = require("../d3/d3");
    var SimpleSplunkView = require("splunkjs/mvc/simplesplunkview");

    require("css!./bubblechart.css");

    var BubbleChart = SimpleSplunkView.extend({

        className: "splunk-toolkit-bubble-chart",

        options: {
            managerid: null,   
            data: "preview", 
            nameField: null,
            valueField: 'count',
            categoryField: null
        },

        output_mode: "json",

        initialize: function() {
            _.extend(this.options, {
                formatName: _.identity,
                formatTitle: function(d) {
                    return (d.source.name + ' -> ' + d.target.name +
                            ': ' + d.value); 
                }
            });
            SimpleSplunkView.prototype.initialize.apply(this, arguments);

            this.settings.enablePush("value");

            // in the case that any options are changed, it will dynamically update
            // without having to refresh. copy the following line for whichever field
            // you'd like dynamic updating on
            this.settings.on("change:valueField", this.render, this);
            this.settings.on("change:nameField", this.render, this);
            this.settings.on("change:categoryField", this.render, this);

            // Set up resize callback. The first argument is a this
            // pointer which gets passed into the callback event
            $(window).resize(this, _.debounce(this._handleResize, 20));
        },

        _handleResize: function(e){
            
            // e.data is the this pointer passed to the callback.
            // here it refers to this object and we call render()
            e.data.render();
        },

        createView: function() {

            // Here we wet up the initial view layout
            var margin = {top: 0, right: 0, bottom: 0, left: 0};
            var availableWidth = parseInt(this.settings.get("width") || this.$el.width());
            var availableHeight = parseInt(this.settings.get("height") || this.$el.height());

            this.$el.html("");

            var svg = d3.select(this.el)
                .append("svg")
                .attr("width", availableWidth)
                .attr("height", availableHeight)
                .attr("pointer-events", "all");
                
            var tooltip = d3.select(this.el).append("div")
                .attr("class", "bubble-chart-tooltip");

            // The returned object gets passed to updateView as viz
            return { container: this.$el, svg: svg, margin: margin, tooltip: tooltip};
        },

        // making the data look how we want it to for updateView to do its job
        formatData: function(data) {
            // getting settings
            var nameField = this.settings.get('nameField');
            var valueField = this.settings.get('valueField');
            var categoryField = this.settings.get('categoryField');
            var collection = data;
            var bubblechart = { 'name': nameField+"s", 'children': [ ] }; // how we want it to look

            // making the children formatted array
            for (var i=0; i < collection.length; i++) {
                var Idx = -1;
                $.each(bubblechart.children, function(idx, el) {
                    if (el.name == collection[i][categoryField]) {
                        Idx = idx;
                    }
                });
                if (Idx == -1) {
                    bubblechart.children.push({ 'name': collection[i][categoryField], children: [ ] });
                    Idx = bubblechart.children.length - 1;
                }

                bubblechart.children[Idx].children.push({ 'name': collection[i][nameField], 'size': collection[i][valueField] || 1 });
            }
            return bubblechart; // this is passed into updateView as 'data'
        },

        updateView: function(viz, data) {
            var that = this;

            // Clear svg
            var svg = $(viz.svg[0]);
            svg.empty();
            
            var tooltip = viz.tooltip;

            // Add the graph group as a child of the main svg
            var graph = viz.svg
                .append("g")
                .attr("class", "bubble")
                .attr("transform", "translate(" + viz.margin.left + "," + viz.margin.top + ")");

            // Set format and color
            var format = d3.format(",d");
            var color = d3.scale.category20c();

            // We have two phases in layout. We tell the 
            // d3 lout how much room it has, then set
            // the sizes of it's containers to match
            // the size it returns. 
            var containerHeight = this.$el.height();
            var containerWidth = this.$el.width();  
            var diameter = Math.min(containerWidth, containerHeight);

            // Tell the layout to layout
            var bubble = d3.layout.pack()
                .sort(null)
                .size([diameter, diameter])
                .padding(1.5);

            // Set containers' sizes to match actual layout
            var width = bubble.size()[0];
            var height = bubble.size()[1];
            graph.attr("width", width)
                .attr("height", height);
            svg.height(height);
            svg.width(width);

            var node = graph.selectAll(".node")
                .data(bubble.nodes(classes(data))
                .filter(function(d) { return !d.children; }))
                .enter().append("g")
                .attr("class", "node")
                .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; });

            // NOTE: this is taken out because we have a custom tooltip.
            // It may need to be put back for accessibility
            // node.append("title")
            //     .text(function(d) { return d.className + ": " + format(d.value); });

            node.append("circle")
                .attr("r", function(d) { return d.r; })
                .style("fill", function(d) { return color(d.packageName); });

            node.append("text")
                .attr("dy", ".3em")
                .style("text-anchor", "middle")
                // ensure the text is truncated if the bubble is tiny
                .text(function(d) { return (d.className + " " + format(d.value)).substring(0, d.r / 3); });

            // Re-flatten the child array
            function classes(data) {
                var classes = [];
                function recurse(name, node) {
                    if (node.children) 
                        node.children.forEach(function(child) { 
                            recurse(node.name, child); 
                        });
                    else 
                        classes.push({packageName: name || "", className: node.name || "", value: node.size});
                }

                recurse(null, data);
                return {children: classes};
            }

            // Tooltips
            function doMouseEnter(d){
                var text;
                if(d.className === undefined || d.className === ""){
                    text = "Event: " + d.value;
                } else {
                    text = d.className+": " + d.value;
                }
                tooltip
                    .text(text)
                    .style("opacity", function(){
                        if(d.value !== undefined) { return 1; }
                        return 0;
                    })
                    .style("left", (d3.mouse(that.el)[0]) + "px")
                    .style("top", (d3.mouse(that.el)[1]) + "px"); 
            }

            // More tooltips
            function doMouseOut(d){
                tooltip.style("opacity", 1e-6);
            }

            node.on("mouseover", doMouseEnter);
            node.on("mouseout", doMouseOut);
            
            // Drilldown clickings. edit this in order to change the search token that 
            // is set to 'value' (a token in bubbles django), this will change the drilldown
            // search.
            node.on('click', function(e) { 
                var clickEvent = {
                    name: e.className,
                    category: e.packageName,
                    value: e.value
                };
                that.settings.set("value", e.className);
                that.trigger("click", clickEvent);
            });
        }
    });
    return BubbleChart;
});