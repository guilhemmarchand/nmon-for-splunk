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
    appUtils.checkEmptyTokenFocus("AIX_metric", appUtils.getToken("AIX_metric"));
    appUtils.checkEmptyTokenFocus("Linux_metric", appUtils.getToken("Linux_metric"));
    appUtils.checkEmptyTokenFocus("Solaris_metric", appUtils.getToken("Solaris_metric"));

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

    defaultTokenModel.on("change:AIX_metric", function(model, value, options) {
      appUtils.checkEmptyTokenFocus("AIX_metric", value);
      if (typeof value !== 'undefined' && value.toString().trim() === "") {
        appUtils.setToken("form.AIX_metric", undefined, true);
      }
    });

    defaultTokenModel.on("change:Linux_metric", function(model, value, options) {
      appUtils.checkEmptyTokenFocus("Linux_metric", value);
      if (typeof value !== 'undefined' && value.toString().trim() === "") {
        appUtils.setToken("form.Linux_metric", undefined, true);
      }
    });

    defaultTokenModel.on("change:Solaris_metric", function(model, value, options) {
      appUtils.checkEmptyTokenFocus("Solaris_metric", value);
      if (typeof value !== 'undefined' && value.toString().trim() === "") {
        appUtils.setToken("form.Solaris_metric", undefined, true);
      }
    });

    appUtils.submitTokens();
  });
}).call(this);
