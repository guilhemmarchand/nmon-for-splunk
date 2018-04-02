/**
 * @fileoverview Class definition for TogglePanel or Accordion panel feature
 * @author Ryan Thibodeaux
 * @version 1.0.0
 */

/*
 * Copyright (c) 2016-2017, OctoInsight Inc., All rights reserved.
 * Authored by Ryan Thibodeaux
 * see included LICENSE file (BSD 3-clause)
 */

/*
 * Definition of custom TogglePanel class.
 * This turns a Splunk "panel" element into
 * an Accordion panel or toggle-able panel.
 *
 * NOTE: this is not an extension of the panel
 * base class; instead, it allows one to retroactively
 * turn an existing panel into a toggle-able one. This
 * makes managing panels easier in Simple XML dashboards
 * because the Simple XML dashboards don't have to know
 * about this class, i.e., it is done in JS for the
 * dashboard
 */

define(function(require, exports, module) {

  var $ = require('jquery');
  var mvc = require("splunkjs/mvc");

  // The require-css plugin is inconsistent at determining the path
  // for loading CSS files. We have to hardcode for now,
  require('css!/static/app/nmon/components/togglepanel/togglepanel.css');


  // default settings for TogglePanel object
  var defaults = {
    openWidth   : undefined,   // width of toggle panel when open
    closeWidth  : undefined,   // width of toggle panel when closed
    toggleSpeed : 500,         // toggle animation duration in milliseconds
  };

  // constructor of TogglePanel object
  // parent can be an HTML id or jquery selector
  function TogglePanel(parent, openWidth, closeWidth, toggleSpeed) {
    if (!(this instanceof TogglePanel)) {
      throw new TypeError("TogglePanel constructor cannot be called as a function.");
    }

    // handle parent parameter passed in as HTML id or jquery selector.
    // this.parent should point to jquery selector of TogglePanel object
    // this.parentId should contain the parent's HTML id
    if (typeof parent === 'undefined') {
      throw new TypeError("TogglePanel constructor cannot be called without a parent.");
    } else if (typeof parent === 'string' || parent instanceof String) {
      this.parentId = parent.replace(/^\#+/g, '');
      this.parent = $('#' + parent);
      if (!this.parentId.length) {
        throw new TypeError("TogglePanel constructor cannot find specified parent.");
      }
    } else {
      this.parentId = $(parent).attr('id');
      this.parent = $(parent);
    }

    // set TogglePanel parameters
    this.openWidth = (typeof openWidth !== 'undefined' ? openWidth : defaults.openWidth);
    this.closeWidth = (typeof closeWidth !== 'undefined' ? closeWidth : defaults.closeWidth);
    this.toggleSpeed = (typeof toggleSpeed !== 'undefined' ? toggleSpeed : defaults.toggleSpeed);
    this.fieldset = undefined;
    this.childrenMvc = undefined;
  }

  // create() wrapper for Toggle Panel constructor
  TogglePanel.create = function(parent, openWidth, closeWidth, toggleSpeed) {
    return (new TogglePanel(parent, openWidth, closeWidth, toggleSpeed));
  };

  // static CSS class names to use for the open and close
  // state of the TogglePanel
  TogglePanel.OPENED_CLASS = 'toggledopen';
  TogglePanel.CLOSED_CLASS = 'toggledclosed';


  // define the TogglePanel class, which is a wholly new class
  // and not an extension of another
  TogglePanel.prototype = {
    constructor: TogglePanel,

    // toggle child state
    toggleChild: function(el, wait) {
      if (!!wait) {
        el.slideToggle(this.toggleSpeed, function(){return;});
      } else {
        el.slideToggle(this.toggleSpeed);
      }
      el.resize();
    },

    // animate hiding of child
    slideUpChild: function(el, wait) {
      if (!!wait) {
        el.slideUp(this.toggleSpeed, function(){return;});
      } else {
        el.slideUp(this.toggleSpeed);
      }
    },

    // animate showing of child
    slideDownChild: function(el, wait) {
      if (!!wait) {
        el.slideDown(this.toggleSpeed, function(){return;});
      } else {
        el.slideDown(this.toggleSpeed);
      }
    },

    // resize Splunk MVC element
    resizeChild: function(el) {
      el.resize();
    },

    // call toggleChild for all known child elements
    toggleAllChildren: function() {
      var self = this;
      this.childrenMvc.forEach(function(child) {
        self.toggleChild(child.$el);
      });
      return this;
    },

    // call slideUp for all known child elements
    hideAllChildren: function() {
      var self = this;
      this.childrenMvc.forEach(function(child) {
        self.slideUpChild(child.$el);
      });
      return this;
    },

    // call slideDown for all known child elements
    // where we let the animation complete before moving
    // to the next and then we resize after all done
    showAllChildren: function() {
      var self = this;
      this.childrenMvc.forEach(function(child) {
        self.slideDownChild(child.$el, true);
      });
      this.childrenMvc.forEach(function(child) {
        self.resizeChild(child.$el);
      });
      return this;
    },

    // high-level function to start the toggle process on,
    // element el which should toggle all dashboard elements inside
    // of the toggle panel (el) and its fieldset element
    toggle: function(el) {

      if (!el.data('parent')) {
        return;
      }

      // set the toggled state on the contained fieldset element
      // and set the appropriate width of the TogglePanel object el
      var parent = $('#' + el.data('parent'));
      if (parent.length) {

        var fieldset = this.fieldset;

        // if toggling open, set width, toggle the fieldset,
        // and then toggle the elements
        if (el.attr("class") === TogglePanel.CLOSED_CLASS) {
          if (typeof this.openWidth !== 'undefined') {
            parent.css('width', this.openWidth);
          }

          // toggle the fieldset
          if (fieldset.length > 0) {
            fieldset.removeClass("togglepanel-hidden");
            fieldset.slideDown(this.toggleSpeed);
          }

          // call toggle open on all children
          this.showAllChildren();

          // set new toggle icon
          el.attr('class', TogglePanel.OPENED_CLASS);
        } else {
          // if toggling closed, toggle elements,
          // and then toggle the fieldset

          // call slideUp on all children
          this.hideAllChildren();

          // hide the fieldset, where we use slideUp but
          // we also add a class after the animation is complete
          // where this class will force it to be hidden
          if (fieldset.length > 0) {
            fieldset.slideUp(this.toggleSpeed, function() {
              fieldset.addClass("togglepanel-hidden");
            });
          }

          // set the close width
          if (typeof this.closeWidth !== 'undefined') {
            parent.css('width', this.closeWidth);
          }

          // set new toggle icon
          el.attr('class', TogglePanel.CLOSED_CLASS);
        }
      }
      return this;
    },

    // initial function to setup the TogglePanel object
    // by inserting the toggle element at the beginning
    // of the panel title and setting the appropriate state
    // of the TogglePanel based on the hide parameter
    setup: function(hide) {

      // setup html element and its attributes for the toggle icon
      var title = this.parent.find('.panel-title')
      var toggleDiv = $('<div> &nbsp; </div>');
      toggleDiv.attr('class', TogglePanel.OPENED_CLASS);
      toggleDiv.attr('id', "toggle_panel_div_" + this.parentId);
      this.parent.children('.dashboard-panel').prepend(toggleDiv);
      toggleDiv.attr('alt', '#' + this.parentId).data('parent', this.parentId);
      this.$el = toggleDiv

      // save fieldset selector if the panel has one
      this.fieldset = this.parent.find('.fieldset');

      // find all MVC elements and save them in childrenMvc
      var children = [];
      this.parent.find('.dashboard-element').each(function() {
        var k = mvc.Components.get(this.id);
        if (typeof k !== 'undefined') {
          children.push(k);
        }
      });
      this.childrenMvc = children;


      // hide all children if "hide" is true
      if (!!hide) {
        this.toggle(this.$el);
      }

      // setup click listener on toggle switch and panel title
      toggleDiv.on("click", $.proxy(this.toggle, this, this.$el));
      if (title.length > 0) {
        title.first().on("click", $.proxy(this.toggle, this, this.$el));
        title.first().css("cursor", "pointer");
      }
      return this;
    },
  };

  return TogglePanel;
});
