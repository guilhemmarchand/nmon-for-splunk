require(['splunkjs/mvc/simplexml/ready!'], function(){
    require(['splunkjs/ready!', 'splunkjs/mvc'], function(mvc){

                /*
                        --------------------------------------------------------------
                        Multi depends buttons - Written by François Toulouse, thanks !
                        --------------------------------------------------------------

                        Usage: Add an html bootstrap button

                         <button class="btn" data-token-name="foo" data-token-value="1">Activate foo token</button>
                         <button class="btn" data-token-name="bar" data-token-value="1">Activate bar token</button>


                */

        var defaultTokenModel = mvc.Components.getInstance('default', {create: true});
        var submittedTokenModel = mvc.Components.getInstance('submitted', {create: true});

        function setToken(name, value) {
            defaultTokenModel.set(name, value);
            submittedTokenModel.set(name, value);
        }

                function getToken(name) {
                        var ret = null;

            if(defaultTokenModel.get(name) != undefined){
                                ret = defaultTokenModel.get(name);
                        }
                        else if(submittedTokenModel.get(name) != undefined){
                                ret = submittedTokenModel.get(name);
                        }

                        return ret;
        }

        function unsetToken(name) {
            defaultTokenModel.unset(name);
            submittedTokenModel.unset(name);
        }

                // For each button with the class "custom-sub-nav"
                $('.custom-sub-nav').each(function(){
                        var $btn_group = $(this);

                        /* for each button in this nav:
                                - Cliking on the button: create the token "data-token-name" with attribute value "data-token-value"
                                - Button has been clicked already and the user click on it again: removes the token "data-token-name"
                        */
                        $btn_group.find('button').on('click', function(){
                                var $btn = $(this);
                                var btn_current_label = $btn.html();
                                var btn_alt_label = $btn.attr('data-alt-label');
                                var tk_name = $btn.attr('data-token-name');
                                var tk_value = $btn.attr('data-token-value');

                                if( getToken(tk_name) == null){
                                        setToken(tk_name, tk_value);
                                        $btn.addClass('active');
                                }
                                else{
                                        unsetToken(tk_name);
                                        $btn.removeClass('active');
                                }

                                // Manage button label
                                $btn.html(btn_alt_label);
                                $btn.attr('data-alt-label', btn_current_label);

                        });
                });
        });
});