/*jslint vars: true, white: true */
/*global jQuery, IQVOC */

IQVOC.matchAppender = (function($) { // TODO: rename to concept mapper

"use strict";

function MatchAppender(selector) {
  this.root = selector.jquery ? selector : $(selector);
  var remotes = this.root.data("remotes");
  remotes[null] = "Sonstiges"; // XXX: i18n

  var categories = $.map(this.extractCategories(), function(category) {
    return $("<option />").val(category).text(category)[0];
  });

  var input = $("<input />").prependTo(this.root);
  var sources = $.map(remotes, function(name, url) {
    return $("<option />").val(url).text(name)[0];
  });
  $("<select />").append(sources).insertBefore(input);
  $("<button />").text("✓").insertAfter(input).click(onSubmit);
  $("<select />").append(categories).insertAfter(input);
}
MatchAppender.prototype.extractCategories = function() {
  var labels = $("label", this.root);
  return $.map(labels, function(node) { return $(node).text(); });
};

function onSubmit(ev) {
  console.log("DONE");
  ev.preventDefault();
}

return function(selector) {
  return new MatchAppender(selector);
};

}(jQuery));
