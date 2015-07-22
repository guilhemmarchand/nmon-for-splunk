 require(['jquery', 'splunkjs/mvc/simplexml/ready!'], function($) {
     $("[id*=setWidth]").each(function() {
         var match = /setWidth_(\d+(?:_\d+)?)/.exec($(this).attr('id'));
         if (match[1]) {
             $(this).closest(".dashboard-cell").css('width', match[1].replace("_", ".") + '%');
         }
     });
     // Force visualizations (esp. charts) to be redrawn with their new size
     $(window).trigger('resize');
 });