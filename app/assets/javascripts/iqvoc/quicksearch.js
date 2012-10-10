/*jslint vars: true, browser: true, white: true */
/*global jQuery, IQVOC */

IQVOC.quicksearch = (function($) {

"use strict";

var defaults = {
  minLength: 3,
  autoFocus: true,
  source: getConcepts,
  focus: function(ev, ui) { ev.preventDefault(); },
  select: onSelect
};

function onSelect(ev, ui) {
  if(ui.item.value) {
    $(ev.target).val(ui.item.label);
    document.location = ui.item.value;
  }
  ev.preventDefault();
}

function getConcepts(req, callback) {
  var form = $(this.element).closest("form");
  $.ajax({
    type: form.attr("method"),
    url: form.attr("action"),
    data: form.serialize(),
    success: function(data, status, xhr) {
      callback(IQVOC.extractConcepts(data));
    }
  });
}

return function(selector, options) {
  options = options ? $.extend(defaults, options) : defaults;
  $(selector).autocomplete(options);
};

}(jQuery));
