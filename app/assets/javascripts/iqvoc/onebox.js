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
  container.empty();

  $.each(concepts, function(i, concept) {

    var link = $("<a />").attr("href", concept.value).text(concept.label);
    $("<li />").append(link).appendTo(container);
  });
}

return function(selector, options) {
  var container = $(selector);
  var input = container.find("input[type=search]");
  var initialValue = input.val();
  var resultList = $("<ul />").addClass("results").appendTo(container);

  input.keyup(function() {
    var delay = 200;
    clearTimeout(delay);
    setTimeout(function() {
      if (input.val() && input.val() != initialValue) {
        getConcepts(input, resultList);
      }
    }, delay);
  });
};

}(jQuery));
