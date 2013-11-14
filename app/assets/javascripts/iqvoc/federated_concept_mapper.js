/*jslint vars: true, white: true */
/*global jQuery, IQVOC */

IQVOC.FederatedConceptMapper = (function($) {

"use strict";

var baseClass = IQVOC.ConceptMapper;

// `selector` is either a jQuery object, a DOM node or a string
function FederatedConceptMapper(selector) {
  baseClass.apply(this, arguments);

  var sources = this.root.data("remotes"); // TODO: rename data attribute?
  if(!sources) { // fall back to non-federated base class only
    return;
  }
  sources["_custom"] = "Sonstiges"; // FIXME: i18n

  sources = $.map(sources, function(name, url) {
    return $("<option />").val(url).text(name)[0];
  });
  this.source = $("<select />").append(sources).insertBefore(this.input);

  var self = this;
  this.input.autocomplete({ // TODO: extract autocomplete extension into subclass
    source: $.proxy(this, "onChange"),
    search: function(ev, ui) {
      console.log("SEARCH", this, arguments);
      if(self.source.val() === "_custom") {
        return false;
      }
    }
  });
}
FederatedConceptMapper.prototype = new baseClass();
ConceptMapper.prototype.onChange = function(req, callback) {
  console.log("SEARCH", this, arguments);
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

return FederatedConceptMapper;

}(jQuery));
