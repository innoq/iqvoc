/*jslint vars: true, white: true */
/*global jQuery, IQVOC */

IQVOC.conceptMapper = (function($) {

"use strict";

function ConceptMapper(selector) {
  this.root = selector.jquery ? selector : $(selector);
  var remotes = this.root.data("remotes");
  remotes[""] = "Sonstiges"; // XXX: i18n
  var self = this;

  var categories = $.map(this.extractCategories(), function(desc, id) {
    return $("<option />").val(id).text(desc)[0];
  });

  this.input = $("<input />").prependTo(this.root);
  var sources = $.map(remotes, function(name, url) {
    return $("<option />").val(url).text(name)[0];
  });
  this.source = $("<select />").append(sources).insertBefore(this.input);
  $("<button />").text("✓").insertAfter(this.input).
      click($.proxy(this, "onConfirm"));
  this.matchType = $("<select />").append(categories).insertAfter(this.input);

  this.input.autocomplete({
    source: $.proxy(this, "onChange"),
    search: function(ev, ui) {
      if (self.source.val() === "") { return false; }
    }
  });
}
ConceptMapper.prototype.extractCategories = function() {
  var labels = $("label", this.root);
  var data = {};

  $.each(labels, function(i, node) {
    var el = $(node);
    data[el.attr("for")] = el.text();
  });

  return data;
};
ConceptMapper.prototype.onConfirm = function(ev) {
  ev.preventDefault();
  var textAreaInputName = this.matchType.val();

  var textArea = $(document.getElementsByName(textAreaInputName)[0]);
  var newItem = this.input.val();
  var newValue = textArea.val() + ", " + newItem;

  textArea.val($.trim(newValue));
  this.input.val("");
  var matchType = this.extractCategories()[textAreaInputName]; // XXX: inefficient
  this.root.trigger("concept-mapped", {uri: newItem, matchType: matchType });
};
ConceptMapper.prototype.onChange = function(req, callback) {
  var self = this;
  $.ajax({
    type: "GET",
    url: this.root.data("remote-proxy-url"),
    data: {
      prefix: encodeURIComponent(req.term), // Internet is scheiße
      source: this.source.find("option:selected").text(),
      layout: 0
    },
    success: function() {
      var args = Array.prototype.slice.apply(arguments);
      args.push(callback);
      return self.onResults.apply(self, args);
    }
  });
};
ConceptMapper.prototype.onResults = function(html, status, xhr, callback) {
  // this.spinner.hide();
  var doc = $("<div />").append(html);
  var items = $.map(doc.find(".concept-item-link"), function(node, i) {
    var el = $(node);
    return { label: el.text(), value: el.data("resource-url") };
  });
  callback(items);
};

return function(selector) {
  return new ConceptMapper(selector);
};

}(jQuery));
