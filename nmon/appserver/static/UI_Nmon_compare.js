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
    appUtils.checkEmptyTokenFocus("host1", appUtils.getToken("host1"));
    appUtils.checkEmptyTokenFocus("host2", appUtils.getToken("host2"));

    defaultTokenModel.on("change:metric_name", function(model, value, options) {
      appUtils.checkEmptyTokenFocus("metric_name", value);
      if (typeof value !== 'undefined' && value.toString().trim() === "") {
        appUtils.setToken("form.metric_name", undefined, true);
      }
    });

    defaultTokenModel.on("change:host1", function(model, value, options) {
      appUtils.checkEmptyTokenFocus("host1", value);
      if (typeof value !== 'undefined' && value.toString().trim() === "") {
        appUtils.setToken("form.host1", undefined, true);
      }
    });

    defaultTokenModel.on("change:host2", function(model, value, options) {
      appUtils.checkEmptyTokenFocus("host2", value);
      if (typeof value !== 'undefined' && value.toString().trim() === "") {
        appUtils.setToken("form.host2", undefined, true);
      }
    });

    appUtils.submitTokens();
  });
}).call(this);
