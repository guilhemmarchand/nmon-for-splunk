define([
            'jquery',
            'underscore',
            'vizapi/SplunkVisualizationBase',
            'vizapi/SplunkVisualizationUtils',
            'd3'
        ],
        function(
            $,
            _,
            SplunkVisualizationBase,
            vizUtils,
            d3
        ) {
 
    return SplunkVisualizationBase.extend({

        initialize: function() {
            this.$el = $(this.el);
            this.$el.addClass('splunk-horseshoe-meter');
        },

        getInitialDataParams: function() {
            return ({
                outputMode: SplunkVisualizationBase.ROW_MAJOR_OUTPUT_MODE,
                count: 10000
            });
        },

        formatData: function(data, config) {
            // Check empty data
            if(data.rows.length < 1) {
                return false;
            }

            var datum = parseFloat(data.rows[0][0]);

            if(_.isNaN(datum)){
                throw new SplunkVisualizationBase.VisualizationError(
                    'This visualization cannot render non-numeric results. To build a horseshoe meter visualization, use a search that returns numeric values.'
                );
            }

            var formattedData = {
                field: data.fields.length > 0 ? data.fields[0].name : '',
                datum: datum
            }

            return formattedData;
        },
 
        updateView: function(data, config) {
            if (!data) {
                return;
            }

            this.$el.empty();
            
            var height = this.$el.height();
            var width = height;

            var scale = height / 250;

            var outerRadius = width / 2  - 15;
            var innerRadius = outerRadius - 15 * scale;

            var maxValue = this._getEscapedProperty('maxValue', config) || 100;
            var minValue = this._getEscapedProperty('minValue', config) || 0;
            var dialColor = this._getEscapedProperty('dialColor', config) || '#d0d5d9';
            var valueColor = this._getEscapedProperty('valueColor', config) || '#555';
            var backgroundColor = this._getEscapedProperty('backgroundColor', config) || '#fff';
            var underText = this._getEscapedProperty('caption', config) || data.field;

            var useRangemap = this._getEscapedProperty('useRangemap', config) === 'true';

            var thresholdStyle = this._getEscapedProperty('thresholdStyle', config) || 'percentage';
            
            function calculateThreshold(number) {
                return thresholdStyle === 'percentage' ? 
                    +minValue + (number / 100) * (maxValue - minValue) : number;
            }

            var midRangeThreshold = calculateThreshold(this._getEscapedProperty('midRangeThreshold', config) || 55);
            var maxRangeThreshold = calculateThreshold(this._getEscapedProperty('maxRangeThreshold', config) || 80);

            var rangeOneColor = this._getEscapedProperty('minRangeColor', config) || '#3fc77a';
            var rangeTwoColor = this._getEscapedProperty('midRangeColor', config) || '#fbcd2f';
            var rangeThreeColor = this._getEscapedProperty('maxRangeColor', config) || '#b44441';

            this.$el.css('background', backgroundColor)

            var arcScale = d3.scale.linear()
                .domain([minValue, maxValue])
                .range([ - Math.PI * .75, Math.PI * .75])
                .clamp(true);

            var fillArc = d3.svg.arc()
                .startAngle(function(d){
                    return arcScale(minValue);
                })
                .endAngle(function(d){
                    return arcScale(d)
                })
                .innerRadius(innerRadius)
                .outerRadius(outerRadius)

             var meterArc = d3.svg.arc()
                .startAngle(function(d){
                    return arcScale(d);
                })
                .endAngle(function(d){
                    return arcScale(maxValue - 1)
                })
                .innerRadius(innerRadius)
                .outerRadius(outerRadius)

            var colorScale = d3.scale.threshold()
                .domain([midRangeThreshold, maxRangeThreshold])
                .range([rangeOneColor, rangeTwoColor, rangeThreeColor]);

            // SVG setup
            var svg  = d3.select(this.el).append('svg')
                .attr('width', width)
                .attr('height', height)
                .append('g')
                .attr('transform', 'translate(' + width / 2 + ',' + height / 2 + ')');

            // Background arc
            svg.append('path')
                .datum(data.datum)
                .attr('d', meterArc)
                .style('fill', dialColor)
                .style('cursor', 'pointer')
                .on('click', this._drilldown.bind(this));

            // Fill arc
            svg.append('path')
                .datum(data.datum)
                .attr('d', fillArc)
                .style('fill', function(d){
                    return useRangemap ? colorScale(d) : valueColor;
                })
                .style('cursor', 'pointer')
                .on('click', this._drilldown.bind(this));

            var textGroup = svg.append('g')
                .style('cursor', 'pointer')
                .attr('transform', 'scale(' + scale + ')')
                .on('click', this._drilldown.bind(this));

            textGroup.append('text')
                .datum(data.datum)
                .attr('class', 'meter-center-text')
                .style('text-anchor', 'middle')
                .style('fill', function(d){
                    return useRangemap ? colorScale(d) : valueColor;
                })
                .text(function(d){
                    return parseFloat(d);
                })
                .attr('transform', 'translate(' + 0 + ',' + 0 + ')');

            textGroup.append('text')
                .datum(data.datum)
                .attr('class', 'meter-under-text')
                .style('text-anchor', 'middle')
                .style('fill', function(d){
                    return useRangemap ? colorScale(d) : valueColor;
                })
                .text(function(){
                    return underText;
                })
                .attr('transform', 'translate(' + 0 + ',' + 30 + ')');
        },

         _drilldown: function() {
            var data = this.getCurrentData();
            
            var payload = {
                action: SplunkVisualizationBase.FIELD_VALUE_DRILLDOWN,
                data: {}
            };
            payload.data[data.field] = data.datum;
            this.drilldown(payload);
        },

        reflow: function(){
            this.invalidateUpdateView();
        },

        _getEscapedProperty: function(name, config) {
            var propertyValue = config[this.getPropertyNamespaceInfo().propertyNamespace + name];
            return vizUtils.escapeHtml(propertyValue);
        }
    });
});