/*jslint vars: true, white: true */
/*global jQuery, IQVOC */

IQVOC.matchAppender = (function($) { // TODO: rename to concept mapper

"use strict";

function MatchAppender(selector) {
  this.root = selector.jquery ? selector : $(selector);
  var remotes = this.root.data("remotes");
  remotes[null] = "Sonstiges"; // XXX: i18n
  var self = this;

  var categories = $.map(this.extractCategories(), function(desc, id) {
    return $("<option />").val(id).text(desc)[0];
  });

  this.input = $("<input />").prependTo(this.root);
  var sources = $.map(remotes, function(name, url) {
    return $("<option />").val(url).text(name)[0];
  });
  var source = $("<select />").append(sources).insertBefore(this.input);
  $("<button />").text("✓").insertAfter(this.input).
      click($.proxy(this, "onConfirm"));
  this.category = $("<select />").append(categories).insertAfter(this.input);
}
MatchAppender.prototype.extractCategories = function() {
  var labels = $("label", this.root);
  var data = {};

  $.each(labels, function(i, node) {
    var el = $(node);
    data[el.attr("for")] = el.text();
  });

  return data;
};
MatchAppender.prototype.onConfirm = function(ev) {
    ev.preventDefault();
  var textAreaName = this.category.val();

  // Work around faulty simple form generated field prefixes
  var index = textAreaName.indexOf('_') + 1;
  textAreaName = textAreaName.substr(index);

  var textArea = $(document.getElementsByName(textAreaName)[0]);
  var newValue = textArea.val() + "\n" + this.input.val();

  textArea.val($.trim(newValue));
};

function onSubmit(ev) {
  console.log("DONE");
  ev.preventDefault();
}

return function(selector) {
  return new MatchAppender(selector);
};

}(jQuery));
