/*jslint vars: true, white: true */
/*global jQuery, IQVOC */

IQVOC.FederatedConceptMapper = (function($) {

"use strict";

var baseClass = IQVOC.ConceptMapper;

// `selector` is either a jQuery object, a DOM node or a string
function FederatedConceptMapper(selector) {
  baseClass.apply(this, arguments);

  this.noResultsMsg = {
    label: this.root.data("no-results-msg"),
    value: ''
  };

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

  this.indicator = $("<i />").addClass("fa fa-refresh fa-spin").
    css("visibility", "hidden"); // TODO: use `.indicator[.active]` instead; cf. EntitySelector
  this.indicatorWrapper.append(this.indicator);

  var self = this;
  this.input.find('input').autocomplete({ // TODO: extract autocomplete extension into subclass
    source: $.proxy(this, "onChange"),
    search: function(ev, ui) {
      if(self.source.val() === "_custom") {
        return false;
      } else {
        self.indicator.css("visibility", "visible");
      }
    },
    response: function(ev, ui) {
      if (!ui.content.length) {
        ui.content.push(self.noResultsMsg);
      }
      self.indicator.css("visibility", "hidden");
    },
    minLength: 2
  });
}
FederatedConceptMapper.prototype = new baseClass();
FederatedConceptMapper.prototype.onChange = function(req, callback) {
  var self = this;
  $.ajax({
    type: "GET",
    url: this.root.data("remote-proxy-url"),
    data: {
      prefix: encodeURIComponent(req.term), // FIXME: (double-)encoding should not be necessary
      dataset: this.source.find("option:selected").text(),
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
