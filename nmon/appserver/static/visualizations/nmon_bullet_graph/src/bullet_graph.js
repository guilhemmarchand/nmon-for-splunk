define([
            'jquery',
            'underscore',
            'vizapi/SplunkVisualizationBase',
            'vizapi/SplunkVisualizationUtils',
            'd3',
            '../contrib/bullet'
        ],
        function(
            $,
            _,
            SplunkVisualizationBase,
            vizUtils,
            d3,
            d3Bullet
        ) {

    // Truncates a string to a length, optionally adding a suffix
    var truncate = function(str, maxLength, suffix) {
        maxLength = maxLength || 25;
        suffix = suffix || '...';
        str = str || 'null';
        if (str.length > maxLength) {
            str = str.substring(0, maxLength + 1);
            str = str + suffix;
        }
        return str;
    };
 
    return SplunkVisualizationBase.extend({
 
        initialize: function() {
            SplunkVisualizationBase.prototype.initialize.apply(this, arguments);

            this.$el = $(this.el);
            this.$el.addClass('splunk-bullet-graph');
        },

        formatData: function(data) {

            if (!data || data.rows.length < 1) {
                return false;
            }

            // data definition
            // 0 -> title (string)
            // 1 -> current value (number)
            // 2 -> range_low (number)
            // 3 -> range_med (number)
            // 4 -> range_high (number)
            // 5 -> goal (number)
            var result = [];
            var rows = data.rows;

            if (data.fields.length < 5) {
                throw new SplunkVisualizationBase.VisualizationError(
                    'Check the Statistics tab. To generate a bullet graph, the table must include columns representing values in these five fields: <metric_title>, <metric_value>, <range_low>, <range_med>, <range_high>.'
                );
            }

            this.splitFieldName = data.fields[0]['name'];

            _.each(rows, function(row) {
                if (_.isNaN(+row[1]) || _.isNaN(+row[2]) || _.isNaN(+row[3]) || 
                    _.isNaN(+row[4]) || (row[5] && _.isNaN(+row[5]))) {
                    throw new SplunkVisualizationBase.VisualizationError(
                        'Check the Statistics tab. To generate a bullet graph, values in the <metric_value>, <range_low>, <range_med>, <range_high> fields must be numeric.'
                    );
                }

                result.push({
                    title: row[0],
                    ranges: [+row[2], +row[3], +row[4]],
                    measures: [+row[1]],
                    markers: [row[5] ? +row[5] : false]
                });
            });


            return result;
        },
 
        updateView: function(data, config) {

            if (!data || data.length < 1) {
                return
            }

            this.$el.empty();

            var bulletColor = this._getEscapedProperty('bulletColor', config) || '#333';
            var targetMarkerColor = this._getEscapedProperty('targetMarkerColor', config) || '#333';
            var rangeLowColor = this._getEscapedProperty('rangeLowColor', config) || '#cccccc';
            var rangeMidColor = this._getEscapedProperty('rangeMidColor', config) || '#c6c6c6';
            var rangeHighColor = this._getEscapedProperty('rangeHighColor', config) || '#a4a4a4';

            var margin = { top: 5, right: 40, bottom: 20, left: 120 },
                width = this.$el.width() - margin.left - margin.right,
                height = this.$el.height() - margin.top - margin.bottom;

            var bulletHeight = 30;

            var chart = d3.bullet()
                .width(width)
                .height(bulletHeight);

            var svg = d3.select(this.el).selectAll('svg')
                    .data(data)
                .enter().append('svg')
                    .attr('class', 'bullet')
                    .attr('width', width + margin.left + margin.right)
                    .attr('height', bulletHeight + margin.top + margin.bottom)
                .append('g')
                    .on('click', _.bind(this._graphClick, this))
                    .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
                    .call(chart);

            var title = svg.append('g')
                .style('text-anchor', 'end')
                .attr('transform', 'translate(-6,' + (2 * bulletHeight / 3)  + ')');

            title.append('text')
                .attr('class', 'title')
                .text(function(d) { return truncate(d.title, 12); })
                .append('title')
                    .text(function(d) { return d.title; });

            title.append('text')
                .attr('class', 'subtitle')
                .attr('dy', '1em')
                .text(function(d) { return d.subtitle; });

            // colorization
            svg.selectAll('line.marker')
                .style('display', function(d) { return !d ? 'none' : 'block'; })
                .style('stroke', targetMarkerColor);
            svg.selectAll('rect.measure')
                .attr('fill', bulletColor);
            svg.selectAll('rect.range')
                .attr('fill', function(d, i) {
                    var node = d3.select(this);
                    var cls = node.attr('class');
                    if (cls.indexOf('s2') > -1) {
                        return rangeLowColor;
                    } else if (cls.indexOf('s1') > -1) {
                        return rangeMidColor;
                    } else {
                        return rangeHighColor;
                    }
                });

            return this;
        },

        _graphClick: function(d){
            if(d3.event.defaultPrevented) {
                return;
            } 

            var payload = {
                action: SplunkVisualizationBase.FIELD_VALUE_DRILLDOWN,
                data: {}
            };

            payload.data[this.splitFieldName] = d.title;

            this.drilldown(payload, d3.event);
        },

        getInitialDataParams: function() {
            return {
                outputMode: SplunkVisualizationBase.ROW_MAJOR_OUTPUT_MODE,
                count: 10000
            };
        },

        reflow: function() {
            this.invalidateUpdateView();
        },

        _getEscapedProperty: function(name, config) {
            var propertyValue = config[this.getPropertyNamespaceInfo().propertyNamespace + name];
            return vizUtils.escapeHtml(propertyValue);
        }

    });
});