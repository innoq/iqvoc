/*jslint vars: true, browser: true, white: true */
/*global jQuery, IQVOC */

IQVOC.movingSidebar = (function($) {

  "use strict";

  function MovingSidebar(container) {
    this.container = container.jquery ? container : $(container);
    var sidebar = this.container;

    // add data-spy="affix" attribute to activate bootstrap's affix
    this.container.attr('data-spy', 'affix');
    calculateSidebar(sidebar);

    // recalculate on resize
    $(window).on('resize', IQVOC.debounce(function () {
      calculateSidebar(sidebar);
    }, 250));
  }

  function calculateSidebar(sidebar){
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
