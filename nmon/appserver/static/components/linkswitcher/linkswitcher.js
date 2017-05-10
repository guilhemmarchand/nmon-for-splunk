define([
    'underscore',
    'jquery',
    'splunkjs/mvc/basesplunkview',
    'splunkjs/mvc',
    'splunkjs/mvc/simplexml/ready!'
], function(_, $, BaseSplunkView, mvc) {

    /**
     * LinkSwitcherView wraps multiple dashboard elements and allows to switch between them using pills buttons.
     * All wrapped items should be in a grouped dashboard panel (using the <row grouping="..."> attribute).
     *
     * options: {
     *      items: <Array> IDs of the items to wrap
     * }
     *
     */
    var LinkSwitcherView = BaseSplunkView.extend({
        events: {
            'click a.btn-pill': function(e) {
                e.preventDefault();
                var link = $(e.currentTarget);
                var itemId = link.data('item');
                var component = mvc.Components.get(itemId);
                if (component) {
                    this.resetView();
                    link.addClass('active');
                    component.$el.show();
                }
            }
        },
        resetView: function(){
            // Reset active state of the links
            this.$('a.btn-pill').removeClass('active');
            // Hide and reset the styles of all elements
            _(this.settings.get('items')).each(function(id){
                var component = mvc.Components.get(id);
                if(component) {
                    // Update the elements' width and hide the title
                    component.$el.css({ width: '100%' }).hide().find('.panel-head>h3').html('&nbsp;');
                }
            });
        },
        render: function() {
            // Remove previously rendered links
            this.$('.btn-pill').remove();

            if (this.settings.has('items')) {
                var items = this.settings.get('items'), $el = this.$el;
                _(items).each(function(id) {
                    // Lookup the component instance
                    var component = mvc.Components.get(id);
                    if (component) {
                        // Create a new link for each element
                        var link = $('<a class="btn-pill"></a>');
                        link.attr('href', '#' + id).data('item', id);
                        // Use the title of the element as the link text
                        link.text(component.settings.get('title') || "Untitled");
                        link.appendTo($el);
                    }
                });
                this.resetView();

                // Simulate a click on the first link to enable it and view the associated dashboard element
                this.$('a.btn-pill:first').click();
            }
            return this;
        }
    });

    return LinkSwitcherView;
});