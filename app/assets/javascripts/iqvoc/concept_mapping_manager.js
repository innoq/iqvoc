/*jslint vars: true, white: true */
/*global jQuery, IQVOC */

IQVOC.conceptMappingManager = (function($) {

"use strict";

function ConceptMappingManager(selector) {
  this.root = selector.jquery ? selector : $(selector);
  this.conceptMappings = this.populateConceptMappings();

  this.list = $("<ul />").prependTo(this.root);
  this.render();

  var self = this;
  this.root.on("concept-mapped", $.proxy(this, "onUpdate"));
}
ConceptMappingManager.prototype.render = function() {
  var self = this;

  this.list.empty();

  var self = this;
  $.each(this.conceptMappings, function(i, category) {
    $.each(category.values, function(i, uri) {
      self.renderBubble(uri, category.label).appendTo(self.list); // XXX: inefficient
    });
  });
};
ConceptMappingManager.prototype.renderBubble = function(uri, categoryLabel) {
  var category = $("<span />").text(categoryLabel);
  return $("<li />").text(uri).append(category);
};

// [{ el: jQuery Element, values: ["http://uri.de"], label: "Foo" }]
ConceptMappingManager.prototype.populateConceptMappings = function() {
  var textAreas = this.root.find('textarea');

  var labels = {};
  this.root.find("label").each(function(i, node) {
    var el = $(node);
    labels[el.attr("for")] = el.text();
  });

  var urisByLabel = {};
  textAreas.each(function(i, node) {
    var el = $(node);
    var values = $.map($(node).val().split(","), function(item, i) {
      item = $.trim(item);
      return item || null;
    });
    // console.log(labels);
    var label = labels[el.attr("name")];

    urisByLabel[label] = { el: el, values: values };
  });

  return urisByLabel;
};
ConceptMappingManager.prototype.onUpdate = function(ev, data) {
  console.log("onUpdate", this, arguments);
  this.conceptMappings[data.matchType].values.push(data.uri);
  this.render();
};

return function(selector) {
  return new ConceptMappingManager(selector);
};

}(jQuery));
