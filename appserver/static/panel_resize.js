/* This will fix Splunk 6.3.x from failing to resize html panels
Special thanks to the Great VP. F.toulouse !
 */

require(['splunkjs/mvc/simplexml/ready!'], function(){
    require(['splunkjs/ready!'], function(){

        // Search for rows containing at less 3 panels
        $('body .dashboard-row').each(function(row){
            var $row = $(this);

            // Found one -> adjust panels height to highest one
            if( $row.find('.dashboard-cell').length > 2){

                var max_height = Math.max.apply(null, $row.find('.dashboard-cell .dashboard-panel').map(function(){
                    return $(this).height();
                }).get());

                $row.find('.dashboard-cell .dashboard-panel').map(function(){
                    $(this).css('height', max_height+'px');
                });
            }
        });
    });
});