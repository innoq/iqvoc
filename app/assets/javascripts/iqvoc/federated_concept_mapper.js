/*jslint vars: true, white: true */
/*global jQuery, IQVOC */

IQVOC.FederatedConceptMapper = (function($) {

"use strict";

var baseClass = IQVOC.ConceptMapper;

// `selector` is either a jQuery object, a DOM node or a string
function FederatedConceptMapper(selector) {
  baseClass.apply(this, arguments);

  var sources = this.root.data("datasets");
  if(!sources) { // fall back to non-federated base class only
    return;
  }
  sources["_custom"] = this.root.data("translation-other");

  sources = $.map(sources, function(name, url) {
    return $("<option />").val(url).text(name)[0];
  });
  this.source = $("<select />").addClass("form-control").append(sources).
      insertBefore(this.input);

  this.indicator.append($('<span class="input-group-text" />')
    .append('<i class="fa fa-refresh fa-spin" />'));

  var self = this;
  var input = this.input.find("input")

  IQVOC.autocomplete(input, IQVOC.debounce($.proxy(this, "onChange"), 500), {
    noResultsMsg: this.root.data("no-results-msg"),
  });

}
FederatedConceptMapper.prototype = new baseClass();
FederatedConceptMapper.prototype.onChange = function(query, callback) {
  var self = this;

  self.indicator.addClass("active");

  $.ajax({
    type: "GET",
    url: this.root.data("remote-proxy-url"),
    data: {
      prefix: encodeURIComponent(query), // FIXME: (double-)encoding should not be necessary
      dataset: this.source.find("option:selected").text(),
      layout: 0
    },
    success: function() {
      // inject callback
      var args = Array.prototype.slice.apply(arguments);
      args.push(callback);
      return self.onResults.apply(self, args);
    },
    complete: function() {
      self.indicator.removeClass("active");
    }
  });
};
FederatedConceptMapper.prototype.onResults = function(html, status, xhr, callback) {
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
