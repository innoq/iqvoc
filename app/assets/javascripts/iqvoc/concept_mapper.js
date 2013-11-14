/*jslint vars: true, white: true */
/*global jQuery, IQVOC */

IQVOC.conceptMapper = (function($) {

"use strict";

// `selector` is either a jQuery object, a DOM node or a string
function ConceptMapper(selector) {
  this.root = selector.jquery ? selector : $(selector);
  this.matchTypes = this.determineMatchTypes();

  var matchOptions = $.map(this.matchTypes, function(desc, id) {
    return $("<option />").val(id).text(desc)[0];
  });

  var sources = this.root.data("remotes"); // TODO: rename data attribute?
  sources["_custom"] = "Sonstiges"; // FIXME: i18n

  // spawn UI elements

  this.input = $("<input />").prependTo(this.root);
  $("<button />").text("✓").insertAfter(this.input).
      click($.proxy(this, "onConfirm"));
  this.matchType = $("<select />").append(matchOptions).insertAfter(this.input);

  sources = $.map(sources, function(name, url) {
    return $("<option />").val(url).text(name)[0];
  });
  this.source = $("<select />").append(sources).insertBefore(this.input);

  var self = this;
  this.input.autocomplete({ // TODO: extract autocomplete extension into subclass
    source: $.proxy(this, "onChange"),
    search: function(ev, ui) {
      if(self.source.val() === "_custom") {
        return false;
      }
    }
  });
}
ConceptMapper.prototype.delimiter = ", ";
ConceptMapper.prototype.onConfirm = function(ev) {
  ev.preventDefault();

  var textAreaName = this.matchType.val();
  var textArea = document.getElementsByName(textAreaName)[0];
  textArea = $(textArea);

  var newURI = this.input.val();
  var newValue = $.trim(textArea.val() + this.delimiter + newURI);

  textArea.val(newValue);
  this.input.val("");
  this.root.trigger("concept-mapped", {
    uri: newURI,
    matchType: this.matchTypes[textAreaName],
    source: "foo" // TODO
  });
};
ConceptMapper.prototype.onChange = function(req, callback) {
  var self = this;
  $.ajax({
    type: "GET",
    url: this.root.data("remote-proxy-url"),
    data: {
      prefix: encodeURIComponent(req.term), // FIXME: (double-)encoding should not be necessary
      source: this.source.find("option:selected").text(),
      layout: 0
    },
    success: function() {
      // inject callback
      var args = Array.prototype.slice.apply(arguments);
      args.push(callback);
      return self.onResults.apply(self, args);
    }
  });
};
ConceptMapper.prototype.onResults = function(html, status, xhr, callback) {
  var doc = $("<div />").append(html);
  var concepts = doc.find(".concept-item-link");
  var items = $.map(concepts, function(node, i) {
    var el = $(node);
    return { label: el.text(), value: el.data("resource-url") };
  });
  callback(items);
};
ConceptMapper.prototype.determineMatchTypes = function() {
  var data = {};
  $("label", this.root).each(function(i, node) {
    var el = $(node);
    var fieldName = el.attr("for");
    data[fieldName] = el.text();
  });
  return data;
};

return function(selector) {
  return new ConceptMapper(selector);
};

}(jQuery));
