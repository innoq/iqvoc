/*jslint vars: true, white: true */
/*global jQuery, IQVOC */

IQVOC.extractConcepts = (function($) {

"use strict";

function extractConcepts(html) {
  // disable scripts (adapted from jQuery's `load`)
  var rscript = /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi;
  html = html.replace(rscript, "");

  var concepts = $("<div />").append(html).find("ul.concepts li");
  concepts = concepts.map(function(i, node) {
    var el = $("a", node);
    return { value: el.attr("href"), label: $.trim(el.text()) };
  });

  return concepts.length ? Array.prototype.slice.call(concepts, 0) :
      [{ value: null, label: "no matches" }]; // TODO: i18n
}

return function(html) {
  return extractConcepts(html);
};

}(jQuery));
