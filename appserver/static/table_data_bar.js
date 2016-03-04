require([
    'jquery',
    'underscore',
    'splunkjs/mvc',
    'views/shared/results_table/renderers/BaseCellRenderer',
    'splunkjs/mvc/simplexml/ready!'
], function($, _, mvc, BaseCellRenderer) {

    var DataBarCellRenderer = BaseCellRenderer.extend({
        canRender: function(cell) {
            return (cell.field === 'UsedPct');
        },
        render: function($td, cell) {
var pColor="data-bar-under"
if(cell.value > 15){ pColor="data-bar-over" }
            $td.addClass('data-bar-cell').html(_.template('<div class="data-bar-wrapper"><div class="data-bar <%- pColor %>" style="width:<%- percent %>%">&nbsp;<%- ppp %>%</div></div>', {
                percent: Math.min(Math.max(parseFloat(cell.value), 0), 100),
ppp: parseFloat(cell.value).toFixed(2),
pColor: pColor
            }));
        }
    });

    mvc.Components.get('tablebar').getVisualization(function(tableView) {
        tableView.table.addCellRenderer(new DataBarCellRenderer());
        tableView.table.render();
    });

});

