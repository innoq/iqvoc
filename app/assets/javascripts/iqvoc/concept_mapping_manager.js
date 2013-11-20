/*jslint vars: true, white: true */
/*global jQuery, IQVOC */

IQVOC.ConceptMappingManager = (function($) {

"use strict";

function ConceptMappingManager(selector, editable) {
  this.root = selector.jquery ? selector : $(selector);
  this.editable = editable === true;
  this.conceptMappings = this.determineConceptMappings();
  this.datasets = $(document.body).data("datasets");

  this.list = $('<ul class="concept-mappings" />').prependTo(this.root);
  this.render();

  this.root.on("concept-mapped", $.proxy(this, "onUpdate"));
}
ConceptMappingManager.prototype.onDelete = function(ev, instance) {
  var btn = $(this);
  var item = btn.closest("li");

  var matchType = $(".concept-mapping-match-type", item).text();
  var uri = $(".concept-mapping-link", item).attr("href");

  var data = instance.conceptMappings[matchType];
  var values = data.values;
  // XXX: hacky
  var hits = $.map(values, function(value, i) {
    if(value.uri === uri) {
      item.slideUp(function() {
        item.remove();
      });
      return i;
    }
    return null;
  });
  values.splice(hits[0], 1);

  var uris = $.map(data.values, function(value) { return value.uri; });
  data.el.val(uris.join(", "));
};
ConceptMappingManager.prototype.render = function() {
  var self = this;

  var items = [];
  $.each(this.conceptMappings, function(label, category) {
    $.each(category.values, function(i, item) {
      item = self.renderBubble(item, label);
      items.push(item[0]);
    });
  });

  this.list.empty().append(items);
};
ConceptMappingManager.prototype.renderBubble = function(item, categoryLabel) {
  var category = $('<span class="concept-mapping-match-type">').
      text(categoryLabel);
  var dataset = this.determineDataset(item.uri) || "";
  dataset = $('<span class="concept-mapping-dataset" />').text(dataset.name);
  if(this.editable) {
    var self = this;
    var btn = $("<span />").text("DELETE").click(function() {
      // inject instance
      var args = Array.prototype.slice.apply(arguments);
      args.push(self);
      return self.onDelete.apply(this, args);
    });
  }
  var link = $('<a class="concept-mapping-link unlabeled" />').attr("href", item.uri).
      text(item.uri);
  return $('<li class="concept-mapping" />').append(link).append(category).
      prepend(dataset).append(btn);
};

// [{ el: jQuery Element, values: ["http://uri.de"], label: "Foo" }]
ConceptMappingManager.prototype.determineConceptMappings = function() {
  return this.editable ? this.readFromTextArea() : this.readFromLinks();
};
ConceptMappingManager.prototype.readFromLinks = function() { // TODO: rename
  var urisByMatchType = {};
  $(".relation.panel", this.root).each(function(i, node) { // match-type panels
    var container = $(node);
    var matchType = container.find("h2").text();
    var mappings = container.find(".entity_list a");
    urisByMatchType[matchType] = {
      values: $.map(mappings, function(node) {
        return { uri: $(node).attr("href") };
      })
    };
  });
  return urisByMatchType;
};
ConceptMappingManager.prototype.readFromTextArea = function() { // TODO: rename
  var textAreas = this.root.find("textarea");

  var labels = {};
  this.root.find("label").each(function(i, node) {
    var el = $(node);
    labels[el.attr("for")] = el.text();
  });

  var urisByLabel = {};
  textAreas.each(function(i, node) {
    var el = $(node);
    var label = labels[el.attr("name")];
    var values = $.map($(node).val().split(","), function(item, i) {
      item = $.trim(item);
      return item ? { uri: item } : null;
    });

    urisByLabel[label] = { el: el, values: values };
  });

  return urisByLabel;
};
ConceptMappingManager.prototype.onUpdate = function(ev, data) {
  this.conceptMappings[data.matchType].values.push({ uri: data.uri });
  this.render();

  $(document.body).trigger("concept-label", this.list);
};
ConceptMappingManager.prototype.determineDataset = function(uri) {
  var result = null;
  $.each(this.datasets, function(url, name) {
    if(uri.indexOf(url) === 0) {
      result = { name: name, url: url };
      return false;
    }
  });
  return result;
};

return ConceptMappingManager;

}(jQuery));
