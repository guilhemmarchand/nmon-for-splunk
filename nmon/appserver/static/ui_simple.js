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

    appUtils.checkEmptyTokenFocus("frameID", appUtils.getToken("frameID"));
    appUtils.checkEmptyTokenFocus("host", appUtils.getToken("host"));
    appUtils.checkEmptyTokenFocus("device", appUtils.getToken("device"));

    defaultTokenModel.on("change:frameID", function(model, value, options) {
      appUtils.checkEmptyTokenFocus("frameID", value);
      if (typeof value !== 'undefined' && value.toString().trim() === "") {
        appUtils.setToken("form.frameID", undefined, true);
      }
    });

    defaultTokenModel.on("change:host", function(model, value, options) {
      appUtils.checkEmptyTokenFocus("host", value);
      if (typeof value !== 'undefined' && value.toString().trim() === "") {
        appUtils.setToken("form.host", undefined, true);
      }
    });

    defaultTokenModel.on("change:device", function(model, value, options) {
      appUtils.checkEmptyTokenFocus("device", value);
      if (typeof value !== 'undefined' && value.toString().trim() === "") {
        appUtils.setToken("form.device", undefined, true);
      }
    });

    appUtils.submitTokens();
  });
}).call(this);
