// This code has been imported from the following nice work: https://splunkbase.splunk.com/app/3171/

// Author: Ryan Thibodeaux
//
//
// Utility functions used throughout
// other modules and funcitons in the app.


(function() {
  define([
    "jquery",
    "underscore",
    "appOptions",
    "splunkjs/mvc",
    "splunkjs/mvc/simplexml/ready!",
  ], function($, _, appOptions, mvc) {

    var appUtils;
    var footerRemovalTimerOn = 0;

    var submittedTokenModel = mvc.Components.get('submitted');
    var defaultTokenModel   = mvc.Components.get('default');

    if (typeof mvc === 'undefined' || !submittedTokenModel || !defaultTokenModel) {
      var str = "Failed to load Splunk components. " +
        "This is probably a symptom of a bigger problem.";
      alert(str);
      console.error(str);
    }

    return appUtils = (function() {

      function appUtils() {} // empty constructor


      // Initializes app tokens and set footer removal timer
      appUtils.initiliazeApp = function(submit) {

        // make sure appName and pageName are set, and set
        // the 'my_app' and 'my_view' tokens accordingly
        var myApp = appOptions.getOptionValue('appName');
        var myView = appOptions.getOptionValue('pageName');
        if (typeof myApp === 'undefined' || myApp.toString().trim().length < 1 ||
          typeof myView === 'undefined' || myView.toString().trim().length < 1) {

          var comps = (location.pathname.split('?')[0]).split('/');
          var idx = comps.indexOf('app');
          myApp = comps[idx + 1];
          myView = comps[idx + 2];

          appOptions.setOptionValue('appName', myApp);
          appOptions.setOptionValue('pageName', myView);
        }

        appUtils.setToken('my_app', myApp);
        appUtils.setToken('my_view', myView);

        if (!!submit) { //!!undefined is false
          appUtils.submitTokens();
        }

        // make sure pageStartTime is set
        var startTime = appOptions.getOptionValue('pageStartTime');
        if (typeof startTime === 'undefined' || startTime <= 0) {
          startTime = new Date().valueOf();
          appOptions.setOptionValue('pageStartTime', startTime);
        }

        // set timer to remove footer instead of relying on
        // page 'load' event (that was unreliable)
        appUtils.setFooterEditTimer(200);
      };


      // return token model objects
      appUtils.getTokenModels = function() {
        return ([defaultTokenModel, submittedTokenModel]);
      }


      // set generic wildcard tooltip on passed element name(s) where
      // inputs can be an array or a comma-delimited list
      appUtils.setWildCardTooltip = function(inputElements) {

        if (typeof inputElements === 'undefined' || inputElements.length < 1) {
          return;
        }

        var newArray = inputElements;

        // test if not an Array - turn it into one if it is not
        if (Object.prototype.toString.call(inputElements) !== '[object Array]') {
          newArray = inputElements.replace(/^,+|,+$/gm, '').split(",");
        }

        var len = newArray.length;

        for (var i = 0; i < len; i++) {
          appUtils.setTooltip(newArray[i], 'Use \"*\" as a wildcard');
        }
      };


      // set the 'tip' string as the tooltip for element 'name'
      appUtils.setTooltip = function(name, tip) {

        if (typeof name === 'undefined' || name.length < 1 || typeof tip === 'undefined') {
          return;
        }

        var eleID = (name[0] === '#' ? name : '#' + name);
        var e = $(eleID);

        // element exists, so add tooltips
        if (e.length) {

          // add tooltips to text inputs
          var textChild = e.children('div.splunk-textinput');
          if (textChild.length) {
            textChild.attr('title', tip);
            var textChildInputs = textChild.find('input');
            if (textChildInputs.length) {
              textChildInputs.attr('placeholder', tip);
            }
          }

          // add tooltips to multiselect and dropdown inputs
          var msChild = e.children('div.splunk-choice-input');
          if (msChild.length) {
            msChild.attr('title', tip);
          }
        }
      };


      // remove links from Splunk footer
      appUtils.hideFooterLinks = function() {

        footerRemovalTimerOn = 0;

        var footer = $('#footer');

        if (footer.length > 0) {
          links = footer.find('a');
          if (links.length > 0) {
            links.hide();

            // hide the "Hide Filters" link on top of the
            // dashboard if it is present
            var hideLink = $('.hide-global-filters');
            if (hideLink.length > 0) {
              hideLink.hide();
            }

          } else {
            appUtils.setFooterEditTimer();
          }
        }
      };


      // setup timer to remove links from Splunk footer, where
      // the footer is checked 'delayMS' milliseconds from now
      appUtils.setFooterEditTimer = function(delayMS) {

        // set default delay for when to check for footer
        // if delayMS was not set
        if (Math.floor(delayMS) > 1) {} else {
          delayMS = 1000;
        }

        // don't allow setting this timer after page has been loaded
        // for more than 60 seconds
        if (appUtils.getPageLoadedSecs() > 60) {
          return;
        }

        // only allow assessing the footer if the footer is on
        // the dashboard, i.e., hideFooter is not true
        if ($('#footer').length > 0) {
          if (!footerRemovalTimerOn) {
            setTimeout(appUtils.hideFooterLinks, delayMS);
            footerRemovalTimerOn = 1;
          }
        }
      };


      // number of seconds the page has been loaded
      appUtils.getPageLoadedSecs = function() {
        return ((new Date().valueOf() - appOptions.getOptionValue('pageStartTime')) / 1000);
      };


      // Sets token 'name' to 'value' in submittedTokenModel and
      // defaultTokenModel unless excludeDefault is set to true
      appUtils.setSubmittedToken = function(name, value, excludeDefault) {
        if (typeof name === 'undefined' || !submittedTokenModel) {
          return;
        }
        if (!excludeDefault) {
          appUtils.setDefaulToken(name, value);
        }
        submittedTokenModel.set(name, value);
      };

      // Sets token 'name' to 'value' in defaultTokenModel.
      appUtils.setDefaulToken = function(name, value) {
        if (typeof name === 'undefined' || !defaultTokenModel) {
          return;
        }
        defaultTokenModel.set(name, value);
      };

      // Sets token 'name' to 'value' in defaultTokenModel and
      // submit all tokens if set
      appUtils.setToken = function(name, value, submit) {
        appUtils.setDefaulToken(name, value);

        if (!!submit) {
          appUtils.submitTokens();
        }
      };

      // Returns value of token 'name' in defaultTokenModel and
      appUtils.getDefaultToken = function(name) {
        if (typeof name === 'undefined' || !defaultTokenModel) {
          return undefined;
        }
        return defaultTokenModel.get(name);
      };

      // Returns value of token 'name' in submittedTokenModel and
      appUtils.getSubmittedToken = function(name) {
        if (typeof name === 'undefined' || !submittedTokenModel) {
          return undefined;
        }
        return submittedTokenModel.get(name);
      };

      // Returns value of token 'name' in token model 'model'
      appUtils.getToken = function(name, model) {
        var tokens = (typeof model === 'undefined') ? defaultTokenModel : model;

        if (typeof name === 'undefined' || !tokens) {
          return undefined;
        }

        return tokens.get(name);
      };


      // Copy defaultTokenModel values into submittedTokenModels
      appUtils.submitTokens = function() {
        if (submittedTokenModel && defaultTokenModel) {
          submittedTokenModel.set(defaultTokenModel.toJSON());
        }
      };

      // Return boolean answer to if 'checkval' matches 'newval'
      appUtils.checkTokenValue = function(checkval, newval) {
        return (newval === checkval ? true : false);
      };


      // Jumps to div element eleID
      appUtils.scrollIntoView = function(eleID, setting) {
        var e = document.getElementById(eleID);
        if (!!e && e.scrollIntoView) {
          e.scrollIntoView(setting);
        }
      };


      // return if a token is set or not, where "lax" determines
      // if the token is checked if it is an empty value as well
      appUtils.checkEmptyValue = function(value, lax) {
        if (!!lax) {
          return (typeof value === 'undefined')
        } else {
          return (typeof value === 'undefined' || value.length < 1)
        }
      };

      // Toggles visibility of HTML elements of a dashboard
      appUtils.hideHtmlElement = function(eleID, hide) {
        if (appUtils.checkEmptyValue(eleID)) {
          return;
        }

        var e = (eleID[0] === '#' ? eleID : '#' + eleID);
        if ($(e).length) {
          if (!!hide) {
            $(e).hide();
          } else {
            $(e).show();
          }
        }
      };

      // loop through input elements and evaluate each one for focus
      appUtils.checkEmptyTokenFocusForDashboard = function(inputs) {
        if (typeof inputs === 'undefined') {
          return;
        }

        var len = inputs.length;
        var currentValue = undefined;

        for (var i = 0; i < len; i++) {
          currentValue = (defaultTokenModel.attributes.hasOwnProperty('form.' + inputs[i]) ? appUtils.getToken('form.' + inputs[i]) : appUtils.getToken(inputs[i]));
          appUtils.checkEmptyTokenFocus(inputs[i], currentValue);
        }
      };


      // set border style based on state of 'value'
      appUtils.checkEmptyTokenFocus = function(name, value) {
        var id = (name[0] === '#' ? name : '#' + name);
        var p = $(id);
        if (p.length) {
          if (typeof value === 'undefined' || value.length < 1) {
            appUtils.setInputFocus(p);
            return true;
          } else {
            appUtils.clearInputFocus(p);
            return false;
          }
        }
        return false;
      };

      // set the focus effects on the based element
      appUtils.setInputFocus = function(el) {
        if (el.hasClass('input-text') || el.hasClass('splunk-textinput')) {
          el.find('input[type="text"]').css("border-color", "red").css("box-shadow", "0px 1px 1px rgba(0, 0, 0, 0.075) inset, 0px 0px 8px rgba(222, 79, 79, 0.6");
        } else if (el.hasClass('input-dropdown')) {
          el.find('.select2-choice').css("border-color", "red").css("box-shadow", "0px 1px 1px rgba(0, 0, 0, 0.075) inset, 0px 0px 8px rgba(222, 79, 79, 0.6");
        } else if (el.hasClass('input-multiselect')) {
          el.find('.select2-choices').css("border-color", "red").css("box-shadow", "0px 1px 1px rgba(0, 0, 0, 0.075) inset, 0px 0px 8px rgba(222, 79, 79, 0.6");
        } else {
          el.css("border-style", "double");
        }
      };

      // clear the focus effects on the based element
      appUtils.clearInputFocus = function(el) {
        if (el.hasClass('input-text') || el.hasClass('splunk-textinput')) {
          el.find('input[type="text"]').css("border-color", "").css("box-shadow", "");
        } else if (el.hasClass('input-dropdown')) {
          el.find('.select2-choice').css("border-color", "").css("box-shadow", "");
        } else if (el.hasClass('input-multiselect')) {
          el.find('.select2-choices').css("border-color", "").css("box-shadow", "");
        } else {
          el.css("border-style", "none");
        }
      };


      // add event listener of type to object using the assigned callback
      appUtils.addEvent = function(object, type, callback) {
        if (typeof object === 'undefined') {
          return;
        }
        if (object.addEventListener) {
          object.addEventListener(type, callback, false);
        } else if (object.attachEvent) {
          object.attachEvent("on" + type, callback);
        } else {
          object["on" + type] = callback;
        }
      };

      // redirects to a new page in the current app where urlSegment
      // starts with the new page to go to and newTab indicates if
      // we want to open a new tab or not
      appUtils.drilldownRedirect = function(urlSegment, newTab) {

        if (typeof urlSegment === 'undefined' || urlSegment.toString().trim().length < 1) {
          return;
        }

        // make sure the new segment starts with a '/'
        var segment = urlSegment.toString().trim();
        segment = (segment[0] === '/' ? segment : '/' + segment);

        // get strip everything in the current URL and strip it down
        // to what comes before the current page, including the last '/'
        var uri = window.location.toString();
        var currentPage = appUtils.getToken('my_view');
        var path = uri.substr(0, uri.indexOf(currentPage)).replace(/\/+$/i, '');

        // go to new URL
        if (!!newTab) {
          window.open(path + segment, "_blank");
        } else {
          window.location = path + segment;
        }
      };

      // generate html button in parent element
      // id: id and name to use on the html button
      // label: label/span to apply to the button
      // parent: id of parent html element in which to place the button
      // append?: should append or prepend in parent list of children
      // submit?: should it be a submit button type or not
      // vertical?: is the button used in a vertical list of items
      appUtils.generateButton = function(id, label, parent, append, submit, vertical) {

        var btn = document.createElement('button');
        var span;

        // apply id field
        if (typeof id !== 'undefined' && id.length > 0) {
          btn.id = id;
          btn.name = id;
        }

        // apply label
        if (typeof label !== 'undefined' && label.length > 0) {
          span = document.createElement('span');
          span.innerHTML = label;
          btn.appendChild(span);
        }

        // assign styling and insert if parent is set
        if (typeof parent !== 'undefined' && parent.length > 0) {
          var parentID = (parent[0] === '#' ? parent : '#' + parent);
          var p = $(parentID);

          if (p.length) {

            // set button in its place of the parent
            var t = p.find('.fieldset');
            if (t.length) {
              t = $(t[0]);
              if (!!append) {
                t.append(btn);
              } else {
                t.prepend(btn);
              }
            }
          }
        }

        // set button type classes and CSS
        if (!!submit) {
          btn.className = 'btn btn-primary';
        } else {
          btn.className = 'btn-info btn-app-info';
        }

        // set button CSS based on it being in a
        // vertical stack of items or not
        if (!!vertical) {
          btn.style.verticalAlign = 'middle';
          btn.style.margin = "5px 10px 5px 0px";
        } else {
          btn.style.verticalAlign = 'top';
          btn.style.marginTop = "21px";
          btn.style.marginRight = " 10px";
        }

        return $(btn);
      };

      // strip value of dangerous characters in Splunk and trim the result
      appUtils.cleanTxtString = function(value) {
        if (typeof value === 'undefined' || value.length < 1) {
          return "";
        }
        return value.replace(/%|\||\=|\[|\]|\(|\)/g, "").trim();
      };

      // clean raw input text elements
      // value: current value to clean
      // defaultVal: default value to return if cleaned version is empty/undefined
      // post: function to use to clean passed value
      appUtils.cleanTextInputElement = function(value, defaultVal, post) {

        var cleanedValue = defaultVal;

        if (typeof value !== 'undefined') {

          if (!!post) {
            cleanedValue = post(value.toString());
          } else {
            cleanedValue = appUtils.cleanTxtString(value.toString());
          }

          if (cleanedValue.length < 1) {
            cleanedValue = defaultVal;
          }
        }

        return cleanedValue;
      };


      // Forces the strict ordering of the values in the token of a checkbox
      // group identified by the argument "name". The ordering is determined
      // by the order of the individual checkboxes in the group. The current
      // values of the token is passed via the "value" argument.
      appUtils.enforceCheckboxOrdering = function(name, value) {
        var cb = mvc.Components.getInstance(name);
        if (typeof cb !== 'undefined') {
          var preferred_values_order = [];
          var new_field_list = [];
          var matched = [];
          var choices = cb.options.choices;

          // set list of preferred order based on value ordering in checkbox
          for (var i = 0; i < choices.length; i++) {
            preferred_values_order.push(choices[i]['value']);
          }

          // values that do match entries in ordered_preference
          matched = value.filter(function(x) { return preferred_values_order.indexOf(x) >= 0 });

          // loop through preferred_values_order and add them if they are present in matched
          for (var j = 0; j < preferred_values_order.length; j++) {
            if (matched.indexOf(preferred_values_order[j]) >= 0) {
              new_field_list.push(preferred_values_order[j]);
            }
          }

          appUtils.setToken("form." + name, new_field_list);
        }
      };


      // Setup the modal search tool button and event listeners
      // for the passed instance in "modalObject"
      appUtils.setupModalSearchTool = function(modalObject) {

        if (typeof modalObject !== 'undefined') {

          // Create a button on the top fieldset that will open the modal window
          var modalButton = appUtils.generateButton('btn_modal_open', 'Open Search Tool');
          modalButton.click(function() {
            appUtils.setToken('dd_modal_search_time.earliest', appUtils.getToken('earliest'));
            appUtils.setToken('dd_modal_search_time.latest', appUtils.getToken('latest'));
            modalObject.show();
          });

          // add modal button to end of top fieldset after the last input / submit button
          var topFieldset = $('.dashboard-body').find('.fieldset').first();
          if (topFieldset.length > 0) {
            var topFieldsetChildren = topFieldset.children();
            if (topFieldsetChildren.length > 0) {
              var i = topFieldsetChildren.length - 1;
              for(i; i >= 0 ; i--) {
                var lastChild = $(topFieldsetChildren[i]);
                if (!lastChild.hasClass('form-submit') && !lastChild.hasClass('input')) {
                  // continue, go to next previous child
                } else {
                  lastChild.after(modalButton);
                  break;
                }
              }
              if (i < 0) {
                topFieldset.append(modalButton);
              }
            } else {
              topFieldset.append(modalButton);
            }
          }

          defaultTokenModel.on("change:dd_modal_search_value", function(model, value, options) {
            appUtils.checkEmptyTokenFocus("dd_modal_search_value", value);
          });

          submittedTokenModel.on("change:dd_modal_search_value", function(model, value, options) {
            appUtils.setToken("dd_modal_search_value_internal", appUtils.parseModalSearchTerm("dd_modal_search_value", value), true);
          });
        }
      };


      // Parse and clean the search input string from modal
      // window search tool.
      // Returns the cleaned value.
      // name: name of the token used for the search input text box
      // value: value obtained from the text box
      appUtils.parseModalSearchTerm = function(name, value) {

        if (typeof value === 'undefined') {
          return undefined;
        } else if (value.toString().trim() === "") {
          appUtils.setToken(name, undefined, true);
          return undefined;
        }

        var valueCleaned = value.toString().replace(/\'|\"|\||%|\[|\]|\(|\)|\=/g, '');

        if (valueCleaned !== value) {
            alert('Search string contained disallowed characters (\'\"%|[]()=). They have been stripped in the applied search value.');
        }

        value = valueCleaned.trim();

        if (value === "") {
          alert("Applied search string is empty. Please enter a valid search string.");
          appUtils.setToken(name, undefined, true);
          return undefined;
        }

        return value;
      };


      // Parse and clean selected host. Valid inputs values
      // will be separated into a domain and user token.
      // Returns boolean value indicating if the tokens have changed.
      // name: name of the token used for the input text box
      // value: value obtained from the text box
      appUtils.parseDashboardHostTokens = function(name, value) {

        var newHostValue = undefined;
        var currentHostValue = appUtils.getSubmittedToken('dd_target_host_internal');
        var submit = false;

        if (typeof value !== 'undefined') {

          // trim whitespace
          var cleanedValue = value.trim();

          // reset initial value if nothing is left after cleaning,
          // but don't call submit
          if (cleanedValue.length < 1) {
            appUtils.setToken(name, undefined);
          } else {

            // alert the host if there are disallowed characters
            if (typeof cleanedValue !== 'undefined') {
              var cleanedUser = cleanedValue.replace(/\*|\'|\"|\||%|\[|\]|\(|\)|\=/g, '');
              if (cleanedUser !== cleanedValue) {
                alert("The passed Host value contained disallowed characters (*\'\"%|[]()=). They have been stripped from the applied search.");
              }
              newHostValue = cleanedUser.trim();
            }

            // set user value to undefined if an empty string
            if (typeof newHostValue === 'undefined' || newHostValue.length < 1) {
              alert("The passed Host value is incomplete. Use the Search Tool to choose a Host.");
              newHostValue = undefined;
            }
          }
        }

        // set host token value if different than the current value
        if (newHostValue !== currentHostValue) {
          appUtils.setToken('dd_target_host_internal', newHostValue);
          submit = true;
        }

        return submit;
      };

      // Parse and clean selected user. Valid inputs values
      // will be separated into a domain and user token.
      // Returns boolean value indicating if the tokens have changed.
      // name: name of the token used for the input text box
      // value: value obtained from the text box
      appUtils.parseDashboardUserTokens = function(name, value) {

        var newUserValue = undefined;
        var currentUserValue = appUtils.getSubmittedToken('dd_target_user_internal');
        var newDomainValue = undefined;
        var currentDomainValue = appUtils.getSubmittedToken('dd_target_domain_internal');
        var submit = false;

        if (typeof value !== 'undefined') {

          // trim whitespace
          var cleanedValue = value.trim();

          // reset initial value if nothing is left after cleaning,
          // but don't call submit
          if (cleanedValue.length < 1) {
            appUtils.setToken(name, undefined);
          } else {

            // inspect the data for validity
            var regex = /([^\x5c]*)(?:\x5c+)?([^\x5c]*)?/g;
            var match = regex.exec(cleanedValue);
            var dom   = match.length > 1 ? match[1] : undefined;
            var user  = match.length > 2 ? match[2] : undefined;

            // alert the user if there are disallowed characters
            if (typeof user !== 'undefined') {
              var cleanedUser = user.replace(/\*|\'|\"|\||%|\[|\]|\(|\)|\=/g, '');
              if (cleanedUser !== user) {
                alert("The passed User value contained disallowed characters (*\'\"%|[]()=). They have been stripped from the applied search.");
              }
              newUserValue = cleanedUser.trim();
            }

            // alert the user if there are disallowed characters
            if (typeof dom !== 'undefined') {
              var cleanedDomain = dom.replace(/\*|\'|\"|\||%|\[|\]|\(|\)|\=/g, '');
              if (cleanedDomain !== dom) {
                alert("The passed Domain value contained disallowed characters (*\'\"%|[]()=). They have been stripped from the applied search.");
              }
              newDomainValue = cleanedDomain.trim();
            }

            // set user value to undefined if an empty string
            if (typeof newUserValue === 'undefined' || newUserValue.length < 1) {
              alert("The passed User value is incomplete. Use the Search Tool to choose a User.");
              newUserValue = undefined;
            }

            // set domain value to undefined if an empty string
            if (typeof newDomainValue === 'undefined' || newDomainValue.length < 1) {
              alert("The passed Domain value is incomplete. Use the Search Tool to choose a Domain.");
              newDomainValue = undefined;
            }
          }
        }

        // set user token value if different than the current value
        if (newUserValue !== currentUserValue) {
          appUtils.setToken('dd_target_user_internal', newUserValue);
          submit = true;
        }

        // set domain token value if different than the current value
        if (newDomainValue !== currentDomainValue) {
          appUtils.setToken('dd_target_domain_internal', newDomainValue);
          submit = true;
        }
        return submit;
      };

      return appUtils;
    })();
  });
}).call(this);
