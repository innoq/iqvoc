/*jslint vars: true, browser: true, white: true */
/*global jQuery, IQVOC */

IQVOC.movingSidebar = (function($) {

  "use strict";

  function MovingSidebar(container) {
    this.container = container.jquery ? container : $(container);

    // add data-spy="affix" attribute to activate bootstrap's affix
    this.container.attr('data-spy', 'affix');
    calculateSidebar(container);

    // recalculate on resize
    $(window).on('resize', IQVOC.debounce(function () {
      calculateSidebar(container);
    }, 250));
  }

  function calculateSidebar(container){
    var sidebar = $(container);

    if($(document).innerWidth() > 977){
      var parent = sidebar.parent();

      sidebar.attr('style', '');
      sidebar.width(parent.width());
    } else {
      sidebar.attr('style', 'position:relative;');
    }
  };

  return function(selector) {
    return new MovingSidebar(selector);
  };

}(jQuery));
