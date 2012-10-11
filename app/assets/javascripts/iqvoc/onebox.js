/*jslint vars: true, browser: true, white: true */
/*global jQuery, IQVOC */

IQVOC.onebox = (function($) {

"use strict";

var renderResults = function(concepts, container) {
  container.empty();
  $.each(concepts, function(i, concept) {
    var link = $("<a />").attr("href", concept.value).text(concept.label);
    $("<li />").append(link).appendTo(container);
  });
};

var getConcepts = function(input, container) {
  var form = input.closest("form");
  $.ajax({
    type: form.attr("method"),
    url: form.attr("action"),
    data: form.serialize(),
    success: function(data, status, xhr) {
      renderResults(IQVOC.extractConcepts(data), container);
    }
  });
};

return function(selector, options) {
  var container = $(selector);
  var input = container.find("input[type=search]");
  var initialValue = input.val();
  var resultList = $("<ul />").addClass("results").appendTo(container);

  input.keyup(function() {
    if (input.val().length == 0) {
      resultList.empty();
    }
    else if (input.val().length > 0 && input.val() != initialValue) {
      setTimeout(function() { getConcepts(input, resultList) }, 200);
    }
  });
};

}(jQuery));
