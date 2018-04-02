/**
 * @fileoverview Setup the paths and load the Developer Gadgets components
 * @author Ryan Thibodeaux
 * @version 1.0.0
 */

/*
 * Copyright (c) 2017, Ryan Thibodeaux. All Rights Reserved
 * see included LICENSE file (BSD 3-clause) in the app's root directory
 */

(function() {
  "use strict";

  // configure the RequrieJS paths
  require.config({
    paths: {
      "appBase"     : "../app/nmon",
      "TogglePanel" : "../app/nmon/components/togglepanel/togglepanel",
    }
  });

}).call(this);


// from app/developer_gadgets/components/togglepanel/wrapper.js
/*
 * Copyright (c) 2016-2017, OctoInsight Inc., All rights reserved.
 * Authored by Ryan Thibodeaux
 * see included LICENSE file (BSD 3-clause) in the folder components/togglepanel
 */

/*
 * This file implements the autodiscover function
 * that finds panels in SimpleXML that should
 * be turned into Toggle Panels based on their
 * HTML IDs matching a specific pattern.
 */

(function() {
  require([
    "underscore",
    "jquery",
    "splunkjs/mvc",
    "TogglePanel",
], function(_, $, mvc, TogglePanel) {

    "use strict";

    const regex = /_togglepanel/i;
    const regexHide = /_togglepanel_true/i;

    _(mvc.Components.toJSON())
      .chain()
      .filter(function(el) {
        var id = $(el).attr("id");
        var dom = $(el).attr("$el");
        if (typeof id !== "undefined" && typeof dom !== "undefined") {
          if (id.match(regex) !== null && dom.hasClass('dashboard-cell')) {
            return el;
          }
        }
      }).each(function(el) {
        var id = $(el).attr("id");
        var hide = (id.match(regexHide) !== null ? true : false);
        new TogglePanel(id).setup(hide);
      });

  });
}).call(this);
