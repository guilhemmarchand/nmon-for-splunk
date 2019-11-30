require(['splunkjs/mvc/simplexml/ready!'], function() {
    require(['splunkjs/ready!', 'splunkjs/mvc'], function(mvc) {

        // For each button with the class "custom-sub-nav"
        $('.custom-modal').each(function() {
            var $btn_group = $(this);

            /* for each button in this nav with the class "modal":
                    - retrieve the modal window ID from data-modal-name attr of the button
                    - open the modal
               This trick is required since Splunk 8.0.0 which stripes out the native data-togle

	       Example:

	       <!-- Button trigger modal -->
               <div class="custom-modal">
                 <button type="button" class="btn btn-primary" data-modal-name="exampleModal">
                  Launch demo modal
                 </button>
               </div>

               <!-- Modal -->
               <div class="modal fade" id="exampleModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
                 <div class="modal-dialog" role="document">
                  <div class="modal-content">
                    <div class="modal-header">
                      <h5 class="modal-title" id="exampleModalLabel">Modal title</h5>
                      <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&amp;times;</span>
                      </button>
                    </div>
                    <div class="modal-body">
                      This is a modal window test!
                    </div>
                    <div class="modal-footer">
                      <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                      <button type="button" class="btn btn-primary">Save changes</button>
                    </div>
                  </div>
                </div>
              </div>

            */

            $btn_group.find('button').on('click', function() {
                var $btn = $(this);
                var modal_name = $btn.attr('data-modal-name');
                var modal_id = "#" + modal_name
                $(modal_id).modal();
            });

            $btn_group.find('a').on('click', function() {
                var $btn = $(this);
                var modal_name = $btn.attr('data-modal-name');
                var modal_id = "#" + modal_name
                $(modal_id).modal();
            });

        });
    });
});