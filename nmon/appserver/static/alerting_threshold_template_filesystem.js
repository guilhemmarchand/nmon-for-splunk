require([
    'jquery',
    'underscore',
    'splunkjs/mvc',
    'views/shared/results_table/renderers/BaseCellRenderer',
    'splunkjs/mvc/simplexml/ready!'
], function($, _, mvc, BaseCellRenderer) {

    // red rendering for alerting

    var DataBarCellRenderer1 = BaseCellRenderer.extend({
        canRender: function(cell) {
            return (cell.field === 'max_fs_percent');
        },
        render: function($td, cell) {
var pColor="red-data-bar-under"
if(cell.value > 15){ pColor="red-data-bar-over" }
            $td.addClass('red-data-bar-cell').html(_.template('<div class="red-data-bar-wrapper"><div class="red-data-bar <%- pColor %>" style="width:<%- percent %>%">&nbsp;<%- ppp %>%</div></div>', {
                percent: Math.min(Math.max(parseFloat(cell.value), 0), 100),
ppp: parseFloat(cell.value).toFixed(2),
pColor: pColor
            }));
        }
    });

    mvc.Components.get('element_table_show_lookup_content').getVisualization(function(tableView) {
        tableView.table.addCellRenderer(new DataBarCellRenderer1());
        tableView.table.render();
    });

});
