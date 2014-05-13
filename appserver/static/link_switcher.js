/*
 * Simple link switcher implementation which uses jQuery to inject the switcher elements
 */
require([
    'underscore',
    'jquery',
    'splunkjs/mvc',
    'splunkjs/mvc/simplexml/ready!'
], function(_, $, mvc) {

    $('.link-switcher').each(function() {
        var linkSwitcherContainer = $(this);

        // Grab component instances for the specified item IDs
        var elements = _(linkSwitcherContainer.data('items').split(',')).map(function(id) {
            return mvc.Components.get($.trim(id));
        });

        // Hide all but the first element
        _(elements).chain().each(function(el) {

            var link = $('<a href="#" class="btn-pill"></a>').appendTo(linkSwitcherContainer);
            // Use the title of the dashboard element for the link text
            link.text(el.settings.get('title'));
            // Clear the title of the dashboard element
            el.settings.unset('title');

            link.click(function(e) {
                e.preventDefault();

                // Reset the selected link
                linkSwitcherContainer.find('a.active').removeClass('active');
                // Hide all views
                _(elements).chain().pluck('$el').invoke('hide');

                // Mark clicked link as active
                link.addClass('active');
                // Show the view
                el.$el.show().css({ width: '100%' });

                // Force charts to redraw
                $(window).trigger('resize');
            });

        }).pluck('$el').invoke('hide'); // Hide all elements initially

        // Activate the first link and view by simulating a click on the first link
        linkSwitcherContainer.find('a:first').click();
    });

});