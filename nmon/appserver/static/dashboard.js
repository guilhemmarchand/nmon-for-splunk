/////////////////////////////////////////////////
//
// This is the default entry point for all
// pages in the app.
//
// This file will automatically be loaded
// for all dashboards.
//
/////////////////////////////////////////////////

(function() {
  var appName, appPath;
  var pageOptions, pageName;
  var urlAppComponents, requireRoot;

  // anonymous function to breakdown the URL into app name and page name
  urlAppComponents = (function() {
    var comps = (location.pathname.split('?')[0]).split('/');
    var idx   = comps.indexOf('app');
    var app   = comps[idx + 1];
    var page  = comps[idx + 2];
    return [app, page];
  })();

  // obtain values from previous anonymous function
  appName  = urlAppComponents[0];
  pageName = urlAppComponents[1];

  // save global entities
  pageOptions = {
    "pageStartTime": new Date().valueOf(), // save time of when page is loaded
    "appName"  : appName, // app name
    "pageName" : pageName, // dashboard page name
  };

  // setup paths for rest of the configuration
  requireRoot = "../app";
  appPath     = requireRoot + "/" + appName;

  // configure RequrieJS Paths and Options
  require.config({
    paths: {
      "app"                : requireRoot,
      "appOptions"         : appPath + "/components/lib/options",
      "appUtils"           : appPath + "/components/lib/utils",
    },
    config: {
      "appOptions": {
        "options": pageOptions
      }
    }
  });

  // load the important modules for the dashboards, where we load CSS first
  // and than everything else
  require([], function() {
    require([
      "appOptions",
      "appUtils",
    ], function(ignored, appUtils) {
      // call initialization routine
      appUtils.initiliazeApp(true);
    }, function(err) {
      // error callback
      // the error has a list of modules that failed
      var failedId = err.requireModules && err.requireModules[0];
      requirejs.undef(failedId);
      console.error("Error when loading dependency", err);
    });
  }, function(err) {
    // error callback
    // the error has a list of modules that failed
    var failedId = err.requireModules && err.requireModules[0];
    requirejs.undef(failedId);
    console.error("Error when loading CSS dependency", err);
  });
}).call(this);
