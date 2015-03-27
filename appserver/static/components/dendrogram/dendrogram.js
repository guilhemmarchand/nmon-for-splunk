// Cluster Dendrogram D3.js code taken and modified from http://bl.ocks.org/mbostock/4063570 by Mike Bostock

define(function(require, exports, module) {
    var d3 = require("../d3/d3.layout");
    var SimpleSplunkView = require("splunkjs/mvc/simplesplunkview");
    var _ = require("underscore");
    require("css!./dendrogram.css");

    var Dendrogram = SimpleSplunkView.extend({
        className: "splunk-toolkit-dendrogram",
        options: {
            "managerid": null,
            "data": "preview",
            "root_label": "root_label not set",
            "height": "auto",
            "node_outline_color": "#d62728",
            "node_close_color": "#e7969c",
            "node_open_color": "#ffffff",
            "label_size_color": "#d62728",
            "label_count_color": "#1f77b4",
            "has_size": true,
            "initial_open_level": 1,
            "margin_left": 100,
            "margin_right": 400
        },
        output_mode: "json_rows",
        initialize: function() {
            _(this.options).extend({
                "height_px": 500
            });

            SimpleSplunkView.prototype.initialize.apply(this, arguments);

            this.settings.on("change:order", this.render, this);

            $(window).resize(this, _.debounce(this._handleResize, 20));
        },
        _handleResize: function(e) {
            // e.data is the this pointer passed to the callback.
            // here it refers to this object and we call render()
            e.data.render();
        },
        createView: function() {
            return true;
        },
        // Making the data look how we want it to for updateView to do its job
        formatData: function(data) {
            var height     = this.settings.get("height");
            var height_px  = this.settings.get("height_px");
            var root_label = this.settings.get("root_label");
            var has_size   = this.settings.get("has_size");

            this.settings.set("height_px", height === "auto" ? Math.max(data.length * 30, height_px) : height);

            data = _(data).map(function(row) {
                return _(row).map(function(item, i) {
                    // Convert the string value to number
                    return has_size && i + 1 === row.length ? parseFloat(item) : item;
                });
            });

            var get_sum = function(list) {
                return _(list).pluck(list[0].length - 1).reduce(function(memo, num) { return memo + num; }, 0);
            };

            var nest = function(list) {
                var groups = _(list).groupBy(0);

                return _(groups).map(function(value, key) {
                    var children = _(value)
                        .chain()
                        .map(function(v) {
                            return _(v).rest();
                        })
                        .compact()
                        .value();

                    if(has_size) {
                        var sum   = get_sum(children);
                        var count = children.length;

                        return children.length == 1 && children[0].length === 1 ? { "name": key, "size": children[0][0] } : { "name": key, "sum": sum, "count": count, "children": nest(children) };
                    }
                    else {
                        return children.length == 1 && children[0].length === 0 ? { "name": key } : { "name": key, "children": nest(children) };
                    }
                });
            };

            var formatted_data = {
                "name": root_label,
                "children": nest(data)
            };

            if(has_size) {
                _(formatted_data).extend({
                    "sum": get_sum(data),
                    "count": data.length,
                });
            }

            return formatted_data;
        },
        updateView: function(viz, data) {
            this.$el.html("");

            //this.$el.append('<button id="open_all">Open all</button>');
            //this.$el.append('<button id="close_all">Close all</button>');

            //$("#open_all").on("click", function() {
            //    $("g.node_close").click();
            //});

            //$("#close_all").on("click", function() {
            //    $("g.node_open").click();
            //});

            var has_size = this.settings.get("has_size");

            var node_outline_color = this.settings.get("node_outline_color");
            var node_close_color   = this.settings.get("node_close_color");
            var node_open_color    = this.settings.get("node_open_color");
            var label_size_color   = this.settings.get("label_size_color");
            var label_count_color  = this.settings.get("label_count_color");

            var width  = this.$el.width();
            var height = this.settings.get("height_px");

            var m = [20, this.settings.get("margin_right"), 20, this.settings.get("margin_left")],
                w = width - m[1] - m[3],
                h = height - m[0] - m[2],
                i = 0;

            var tree = d3.layout.tree()
                .size([h, w]);

            var diagonal = d3.svg.diagonal()
                .projection(function(d) { return [d.y, d.x]; });

            var vis = d3.select(this.el).append("svg:svg")
                .attr("width", w + m[1] + m[3])
                .attr("height", h + m[0] + m[2])
            .append("svg:g")
                .attr("transform", "translate(" + m[3] + "," + m[0] + ")");

            data.x0 = h / 2;
            data.y0 = 0;

            function toggle_children(tree, level) {
                if(tree.children) {
                    _(tree.children).each(function(child) {
                        toggle_children(child, level+1);
                    });

                    if(level >= initial_open_level) {
                        toggle(tree);
                    }
                }
            }

            var initial_open_level = this.settings.get("initial_open_level");

            if(initial_open_level >= 0) {
                toggle_children(data, 0);
            }

            var duration = 0;
            update(data);
            duration = d3.event && d3.event.altKey ? 5000 : 500;

            function update(source) {
                // Compute the new tree layout.
                var nodes = tree.nodes(data).reverse();

                // Normalize for fixed-depth.
                nodes.forEach(function(d) { d.y = d.depth * 180; });

                // Update the nodes…
                var node = vis.selectAll("g.node")
                    .data(nodes, function(d) { return d.id || (d.id = ++i); });

                // Enter any new nodes at the parent's previous position.
                var nodeEnter = node.enter().append("svg:g")
                    //.attr("class", "node")
                    .attr("class", function(d) { return d._children ? "node node_close" : "node node_open"; })
                    .attr("transform", function(d) { return "translate(" + source.y0 + "," + source.x0 + ")"; })
                    .on("click", function(d) { toggle(d); update(d); });

                nodeEnter.append("svg:circle")
                    .attr("r", 1e-6)
                    .style("fill", function(d) { return d._children ? node_close_color : node_open_color; })
                    .style("cursor", function(d) { return d.children || d._children ? "pointer" : "default"; })
                    .style("stroke", node_outline_color);

                nodeEnter.append("svg:text")
                    .attr("x", function(d) { return d.children || d._children ? -10 : 10; })
                    .attr("dy", ".35em")
                    .attr("text-anchor", function(d) { return d.children || d._children ? "end" : "start"; })
                    .style("cursor", function(d) { return d.children || d._children ? "pointer" : "default"; })
                    .style("fill-opacity", 1e-6)
                    .html(function(d) {
                        if(has_size) {
                            var sum  = Number(d.sum) .toLocaleString('en');
                            var size = Number(d.size).toLocaleString('en');

                            var long_label  = d.name + ' - <tspan fill="' + label_size_color + '">' + sum + '</tspan> - <tspan fill="' + label_count_color+ '">' + d.count + '<tspan>';
                            var short_label = d.name + ' - <tspan fill="' + label_size_color + '">' + size + '<tspan>';

                            return d.children || d._children ? long_label : short_label;
                        }
                        else {
                            return d.name;
                        }
                    });

                // Transition nodes to their new position.
                var nodeUpdate = node.transition()
                    .duration(duration)
                    .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

                nodeUpdate.select("circle")
                    .attr("r", 4.5)
                    .style("fill", function(d) { return d._children ? node_close_color : node_open_color; });

                nodeUpdate.select("text")
                    .style("fill-opacity", 1);

                // Transition exiting nodes to the parent's new position.
                var nodeExit = node.exit().transition()
                    .duration(duration)
                    .attr("transform", function(d) { return "translate(" + source.y + "," + source.x + ")"; })
                    .remove();

                nodeExit.select("circle")
                    .attr("r", 1e-6);

                nodeExit.select("text")
                    .style("fill-opacity", 1e-6);

                // Update the links…
                var link = vis.selectAll("path.link")
                    .data(tree.links(nodes), function(d) { return d.target.id; });

                // Enter any new links at the parent's previous position.
                link.enter().insert("svg:path", "g")
                    .attr("class", "link")
                    .attr("d", function(d) {
                        var o = {x: source.x0, y: source.y0};
                        return diagonal({source: o, target: o});
                    })
                    .transition()
                    .duration(duration)
                    .attr("d", diagonal);

                // Transition links to their new position.
                link.transition()
                    .duration(duration)
                    .attr("d", diagonal);

                // Transition exiting nodes to the parent's new position.
                link.exit().transition()
                    .duration(duration)
                    .attr("d", function(d) {
                        var o = {x: source.x, y: source.y};
                        return diagonal({source: o, target: o});
                    })
                    .remove();

                // Stash the old positions for transition.
                nodes.forEach(function(d) {
                    d.x0 = d.x;
                    d.y0 = d.y;
                });
            }

            // Toggle children.
            function toggle(d) {
                if(d.children) {
                    d._children = d.children;
                    d.children = null;
                }
                else {
                    d.children = d._children;
                    d._children = null;
                }
            }
        }
    });
    return Dendrogram;
});
