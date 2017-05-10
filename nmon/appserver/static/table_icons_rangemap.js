require([
    'underscore',
    'jquery',
    'splunkjs/mvc',
    'splunkjs/mvc/tableview',
    'splunkjs/mvc/simplexml/ready!'
], function(_, $, mvc, TableView) {

    // Translations from rangemap results to CSS class
    var ICONS = {
        equal: 'equal-sign-48px',
        increase: 'arrow_red_increase_48px',
        decrease: 'arrow_green_decrease_48px'
    };

    var RangeMapIconRenderer = TableView.BaseCellRenderer.extend({
        canRender: function(cell) {
            // Only use the cell renderer for the range field
            return cell.field === 'range';
        },
        render: function($td, cell) {
            var icon = 'question';
            // Fetch the icon for the value
            if (ICONS.hasOwnProperty(cell.value)) {
                icon = ICONS[cell.value];
            }
            // Create the icon element and add it to the table cell
            $td.addClass('icon').html(_.template('<div class="myicon <%- icon%> title="<%- range %>"></div>', {
                icon: icon,
                range: cell.value
            }));
        }
    });

    mvc.Components.get('table1').getVisualization(function(tableView){
        // Register custom cell renderer
        tableView.table.addCellRenderer(new RangeMapIconRenderer());
        // Force the table to re-render
        tableView.table.render();
    });

});