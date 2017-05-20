// This code has been imported from the following nice work: https://splunkbase.splunk.com/app/3171/

// Author: Ryan Thibodeaux
//
//
// Options module for passing
// parameters between modules/functions.

(function() {
  define([
    "module",
  ], function(module) {

    var appOptions;
    var options = {};
    var config = module.config();

    if (typeof config !== 'undefined' && config !== null) {
      options = config.options;
    }

    return appOptions = (function() {
      function appOptions() {} // empty constructor

      // check if appOptions contains parameter 'name'
      appOptions.hasOption = function(name) {
        if (typeof options === 'undefined' ||
          typeof name === 'undefined' ||
          options.hasOwnProperty(name) !== true) {
          return false;
        }
        return true;
      };

      // return value stored in parameter 'name'
      appOptions.getOptionValue = function(name) {
        return (appOptions.hasOption(name) ? options[name] : undefined);
      };

      // set parameter 'name' to value
      appOptions.setOptionValue = function(name, value) {
        if (!appOptions.hasOption(name)) {
          return false;
        }

        options[name] = value;
        return true;
      };

      return appOptions;
    })();
  });
}).call(this);
