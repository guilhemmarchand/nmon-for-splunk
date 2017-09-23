(function() {
  require([
    "underscore",
    "jquery",
    "splunkjs/mvc",
    "appUtils",
    "splunkjs/ready!",
    "splunkjs/mvc/simplexml/ready!",
  ], function(_, $, mvc, appUtils) {

    /////////////////////////////////////////
    ///  Start Main Code Here
    /////////////////////////////////////////

    var ref = appUtils.getTokenModels();
    var defaultTokenModel = ref[0];
    var submittedTokenModel = ref[1];

    appUtils.checkEmptyTokenFocus("metric_name", appUtils.getToken("metric_name"));
    appUtils.checkEmptyTokenFocus("host", appUtils.getToken("host"));

    defaultTokenModel.on("change:metric_name", function(model, value, options) {
      appUtils.checkEmptyTokenFocus("metric_name", value);
      if (typeof value !== 'undefined' && value.toString().trim() === "") {
        appUtils.setToken("form.metric_name", undefined, true);
      }
    });

    defaultTokenModel.on("change:host", function(model, value, options) {
      appUtils.checkEmptyTokenFocus("host", value);
      if (typeof value !== 'undefined' && value.toString().trim() === "") {
        appUtils.setToken("form.host", undefined, true);
      }
    });

    appUtils.submitTokens();
  });
}).call(this);
