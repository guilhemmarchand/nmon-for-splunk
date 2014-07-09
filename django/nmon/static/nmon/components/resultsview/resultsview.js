define(function(require, exports, module) {

    var _ = require('underscore');
    var SimpleSplunkView = require("splunkjs/mvc/simplesplunkview");

    var ResultsViewer = SimpleSplunkView.extend({

        className: "splunk-toolkit-results-viewer",

        options : {
            "number" : 20,
        },

        output_mode: "json",

        createView: function() {
            
            return true;
        },

        formatData: function(data){
            var number = this.settings.get("number");
            if (data.length > number) {
                data = _.first(data, parseInt(number));
            }

            return data;
        },

        updateView: function(viz, data) {
            var rawFields = this.resultsModel.data().fields;
            
            var fields = rawFields;
            if (!rawFields || rawFields.length === 0) {
                fields = _.keys(data[0]);
            }
            else if (rawFields && _.isObject(rawFields[0])) {
                fields = _.pluck(this.resultsModel.data().fields, "name");   
            }
            
            this.$el.html('');
            this.$el.append(
                '<h5>Fields</h5>'+
                '<pre>' + fields + '</pre>'+
                '<h5>Results (may be truncated)</h5>'+
                '<pre>' + JSON.stringify(data, undefined, 2) + '</pre>');
        },

        getData: function(){
            return this.resultsModel.data().results;
        }
    });
    return ResultsViewer;
});