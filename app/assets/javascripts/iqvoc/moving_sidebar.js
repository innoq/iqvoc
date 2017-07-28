/*jslint vars: true, browser: true, white: true */
/*global jQuery, IQVOC */

IQVOC.movingSidebar = (function($) {

  "use strict";

  function MovingSidebar(container) {
    this.container = container.jquery ? container : $(container);

    // add data-spy="affix" attribute to activate bootstrap's affix
    this.container.attr('data-spy', 'affix');
  }

  return function(selector) {
    return new MovingSidebar(selector);
  };

}(jQuery));
