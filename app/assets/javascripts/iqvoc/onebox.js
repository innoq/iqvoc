/*jslint vars: true, browser: true, white: true */
/*global jQuery, IQVOC */

IQVOC.onebox = (function($) {

"use strict";

function getConcepts(input, container) {
  var form = input.closest("form");

  $.ajax({
    type: form.attr("method"),
    url: form.attr("action"),
    data: form.serialize(),
    success: function(data, status, xhr) {
      renderResults(IQVOC.extractConcepts(data), container);
    }
  });
}

function renderResults(concepts, container) {
  container.html("");

  $(concepts).each(function(i, concept) {
    container.append('<li><a href="' + concept.value + '">' + concept.label + '</a></li>');
  });
}

return function(selector, options) {
  var container = $(selector);
  var input = container.find("input[type=search]");
  var initialValue = input.val();
  var resultList = $("<ul class=results />").appendTo(container);

  input.keyup(function() {
    if (input.val() !== initialValue) {
      getConcepts(input, resultList);
    }
  });
};

}(jQuery));
